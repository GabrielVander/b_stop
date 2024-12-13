use async_trait::async_trait;
use chrono::{DateTime, Local, NaiveDateTime, NaiveTime};
use futures::TryFutureExt;

use crate::features::trips::domain::{
    entities::trip::{Departure, Trip},
    repositories::trip_repository::TripRepository,
};

#[derive(Debug)]
pub struct TripRepositoryHttpImpl {
    base_url: String,
    stop_hash_param_name: String,
}

impl TripRepositoryHttpImpl {
    pub fn new(base_url: String, stop_hash_param_name: String) -> Self {
        Self {
            base_url,
            stop_hash_param_name,
        }
    }

    fn build_target_url(&self, stop_hash: String) -> Result<reqwest::Url, String> {
        log::trace!("Building target URL...");
        let mut url: String = self.base_url.clone();

        if url.ends_with('/') {
            url = url[0..url.len()].to_owned();
        }

        let params = [(&self.stop_hash_param_name, stop_hash)];

        reqwest::Url::parse_with_params(&url, params)
            .inspect_err(|e| log::error!("{e}"))
            .map_err(|_| "Unable to build target URL".to_string())
    }

    async fn perform_request(&self, url: reqwest::Url) -> Result<reqwest::Response, String> {
        log::debug!("Performing HTTP request...");

        reqwest::get(url)
            .inspect_err(|e| log::error!("{e}"))
            .map_err(|_| "Failed to perform request".to_string())
            .await
    }

    async fn parse_http_response(&self, response: reqwest::Response) -> Result<Vec<Trip>, String> {
        log::debug!("Parsing HTTP response...");

        response
            .json::<TripsByStopResponseModel>()
            .map_ok(|model| model.to_entity())
            .inspect_err(|e| log::error!("{e}"))
            .map_err(|_| "Unable to deserialize response body as json".to_string())
            .await
    }
}

#[async_trait]
impl TripRepository for TripRepositoryHttpImpl {
    async fn fetch_all_for_stop(&self, stop_hash: String) -> Result<Vec<Trip>, String> {
        log::debug!("Fetching all trips for stop with hash {stop_hash} via HTTP...");

        futures::future::ready(self.build_target_url(stop_hash))
            .and_then(|url| self.perform_request(url))
            .and_then(|response| self.parse_http_response(response))
            .await
    }
}

use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
struct TripsByStopResponseModel {
    stop_name: String,
    platform: Option<serde_json::Value>,
    time: i64,
    tz_offset: i64,
    trips: Vec<TripResponseModel>,
    alerts: Vec<Option<serde_json::Value>>,
}

impl TripsByStopResponseModel {
    pub fn to_entity(&self) -> Vec<Trip> {
        self.trips.iter().map(|model| model.to_entity()).collect()
    }
}

#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
struct TripResponseModel {
    trip_id: String,
    headsign: String,
    direction_id: i64,
    route_id: String,
    short_name: String,
    long_name: String,
    color: String,
    ac: bool,
    stop_sequence: i64,
    departures: Vec<DepartureResponseModel>,
}

impl TripResponseModel {
    pub fn to_entity(&self) -> Trip {
        Trip {
            id: self.trip_id.clone(),
            line_name: self.long_name.clone(),
            line_number: self.short_name.clone(),
            departures: self
                .departures
                .iter()
                .map(|model| model.to_entity())
                .collect(),
        }
    }
}

#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
struct DepartureResponseModel {
    trip_feed_id: String,
    time: String,
    next_day: bool,
    wa: bool,
    extra: bool,
    time_original: Option<String>,
    position_age: Option<i64>,
    vehicle_id: Option<String>,
    gps_time: Option<String>,
    bearing: Option<i64>,
    delay: Option<i64>,
    stop_sequence: Option<i64>,
}

impl DepartureResponseModel {
    pub fn to_entity(&self) -> Departure {
        Departure {
            id: self.trip_feed_id.clone(),
            time: Local::now()
                .with_time(
                    NaiveTime::parse_from_str(
                        &self.gps_time.clone().unwrap_or(self.time.clone()),
                        "%H:%M:%S",
                    )
                    .expect("Unable to parse time"),
                )
                .unwrap(),
            is_next_day: self.next_day,
            is_time_based_on_gps: self.gps_time.is_some(),
        }
    }
}
