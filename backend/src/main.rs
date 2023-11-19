use bigdecimal::ToPrimitive;
use geo_types::{Geometry, Point};
use geozero::wkb;
use log::error;
use rand::Rng;
use rocket::fairing::{self, AdHoc};
use rocket::serde::json::Json;
use rocket::{get, launch, post, routes, Build, Rocket};
use rocket_db_pools::{Connection, Database};
use serde::{Deserialize, Serialize};

// TODO: unwrap()s

#[derive(Deserialize)]
#[serde(rename_all = "kebab-case")]
struct BoundingBox {
    lat_min: f64,
    lat_max: f64,
    lon_min: f64,
    lon_max: f64,
}

#[derive(Serialize)]
#[serde(rename_all = "kebab-case")]
struct Doener {
    name: String,
    lat: f64,
    lon: f64,
    price_cents: Option<u16>,
    rating: f32,
    address: String,
}

#[launch]
fn rocket() -> _ {
    rocket::build()
        .attach(Db::init())
        .attach(AdHoc::try_on_ignite("SQLx Migrations", run_migrations))
        .mount(
            "/",
            routes![
                index,
                doener_in_bounding_box,
                price_grid_in_bounding_box,
                rating_grid_in_bounding_box
            ],
        )
}

async fn run_migrations(rocket: Rocket<Build>) -> fairing::Result {
    match Db::fetch(&rocket) {
        Some(db) => match sqlx::migrate!().run(&**db).await {
            Ok(_) => {
                // Repopulate data from Google Maps data
                sqlx::query!("DELETE FROM kebab")
                    .execute(&**db)
                    .await
                    .unwrap();
                let data =
                    std::fs::read_to_string("../google_maps_data/munich_doener_df_with_price.json")
                        .unwrap();
                for l in data.lines() {
                    #[derive(Deserialize)]
                    struct JsonData {
                        name: String,
                        address: String,
                        lat: f64,
                        lon: f64,
                        rating: f32,
                        price: Option<String>, // Unfortunate
                    }

                    let data: JsonData = serde_json::from_str(l).unwrap();
                    sqlx::query!(
                        "INSERT INTO kebab (name, address, rating, price_cents, position) VALUES($1, $2, $3, $4, $5::geometry)",
                        data.name,
                        data.address,
                        data.rating,
                        data.price.map(|p| (p.parse::<f32>().unwrap() * 100.0) as i32),
                        wkb::Encode(Geometry::Point(Point::new(data.lon, data.lat))) as _,
                    ).execute(&**db).await.unwrap();
                }
                Ok(rocket)
            }
            Err(e) => {
                error!("Failed to initialize SQLx database: {}", e);
                Err(rocket)
            }
        },
        None => Err(rocket),
    }
}

#[get("/")]
fn index() -> &'static str {
    "Hello, world!"
}

#[derive(Serialize)]
struct Response {
    doener: Vec<Doener>,
    // TODO: selectable size? other grid types? (price, rating)
    grid: [[f32; 16]; 16],
}

#[post("/doener_in_bounding_box", data = "<bb>")]
async fn doener_in_bounding_box(
    bb: Json<BoundingBox>,
    mut db: Connection<Db>,
) -> Json<Vec<Doener>> {
    assert!(bb.lat_min < bb.lat_max && bb.lon_min < bb.lon_max);

    // 4326 is WGS 84
    let results = sqlx::query_as!(
        PointRec,
        r#"
        SELECT name, price_cents, address,rating, position as "position!: _"
        FROM kebab
        WHERE ST_Intersects(
            position,
            ST_MakeEnvelope ($1, $2, $3, $4, 4326)::geography('POLYGON')
        )
    "#,
        bb.lon_min,
        bb.lat_min,
        bb.lon_max,
        bb.lat_max
    )
    .fetch_all(&mut **db)
    .await
    .unwrap();
    // TODO: Limit results somehow?
    let doener = results
        .into_iter()
        .map(|rec| {
            let pos: Point = rec.position.geometry.unwrap().try_into().unwrap();
            Doener {
                name: rec.name,
                lon: pos.x(),
                lat: pos.y(),
                price_cents: rec.price_cents.map(|p| p as u16),
                rating: rec.rating,
                address: rec.address,
            }
        })
        .collect();
    Json(doener)
}

const GRID_SIZE: usize = 16;
// NOTE: Vec<f32> since Serialize isn't implemented for large arrays (TODO: When is const generics )
#[post("/price_grid_in_bounding_box", data = "<bb>")]
async fn price_grid_in_bounding_box(
    bb: Json<BoundingBox>,
    mut db: Connection<Db>,
) -> Json<Vec<u32>> {
    let step_lon = (bb.lon_max - bb.lon_min) / GRID_SIZE as f64;
    let step_lat = (bb.lat_max - bb.lat_min) / GRID_SIZE as f64;
    let mut ret = [0; GRID_SIZE * GRID_SIZE];
    for y in 0..GRID_SIZE {
        for x in 0..GRID_SIZE {
            let lon_low = bb.lon_min + x as f64 * step_lon;
            let lat_low = bb.lat_min + y as f64 * step_lat;
            let lon_high = lon_low + step_lon;
            let lat_high = lat_low + step_lat;
            let avg = sqlx::query!(
                r#"
                    SELECT AVG(price_cents)
                    FROM kebab
                    WHERE ST_Intersects(
                        position,
                        ST_MakeEnvelope ($1, $2, $3, $4, 4326)::geography('POLYGON')
                    )
                "#,
                lon_low,
                lat_low,
                lon_high,
                lat_high
            )
            .fetch_one(&mut **db)
            .await
            .unwrap()
            .avg
            .map(|avg| avg.to_f32().unwrap())
            .unwrap_or(0.);
            ret[y * GRID_SIZE + x] = avg.round() as u32;
        }
    }
    Json(ret.to_vec())
}

#[derive(Database)]
#[database("postgis")]
struct Db(sqlx::PgPool);

#[derive(Debug)]
struct PointRec {
    name: String,
    price_cents: Option<i32>,
    position: wkb::Decode<geo_types::Geometry<f64>>,
    address: String,
    rating: f32,
}
