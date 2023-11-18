#[macro_use]
extern crate rocket;

use rocket::serde::json::Json;
use serde::{Deserialize, Serialize};

#[derive(Deserialize)]
struct BoundingBox {
    lat_min: f32,
    lat_max: f32,
    lon_min: f32,
    lon_max: f32,
}

#[derive(Serialize)]
struct Doener {
    name: String,
    lat: f32,
    lon: f32,
    price_cents: u16,
}

#[launch]
fn rocket() -> _ {
    rocket::build().mount("/", routes![index, doener_in_bounding_box])
}

#[get("/")]
fn index() -> &'static str {
    "Hello, world!"
}

#[post("/doener_in_bounding_box", data = "<bb>")]
fn doener_in_bounding_box(bb: Json<BoundingBox>) -> Json<Vec<Doener>> {
    assert!(bb.lat_min < bb.lat_max && bb.lon_min < bb.lon_max);
    Json(vec![Doener {
        name: "Spicy Doener".to_owned(),
        lat: 0.75 * (bb.lat_max - bb.lat_min) + bb.lat_min,
        lon: 0.5 * (bb.lon_max - bb.lon_min) + bb.lon_min,
        price_cents: 300,
    }])
}
