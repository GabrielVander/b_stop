use futures::TryFutureExt;
use std::env;

use crate::features::trips::{
    data::repositories::trip_repository_http_impl::TripRepositoryHttpImpl,
    domain::{
        entities::trip::{Departure, Trip},
        use_cases::retrieve_trips_for_stop_use_case::RetrieveAllTripsForStopUseCase,
    },
};

pub async fn trips_for_stop(stop_hash: String) -> Result<Vec<TripModel>, String> {
    let base_url = env::var("TRIPS_HTTTP_BASE_URL")
        .inspect_err(|e| log::error!("{e}"))
        .map_err(|_| "Missing environment variable 'TRIPS_HTTTP_BASE_URL'")?;
    let param_name = env::var("TRIPS_HASH_HTTP_QUERY_PARAM_NAME")
        .inspect_err(|e| log::error!("{e}"))
        .map_err(|_| "Missing environment variable 'TRIPS_HASH_HTTP_QUERY_PARAM_NAME'")?;

    let trip_repository_http_impl = TripRepositoryHttpImpl::new(base_url, param_name);
    let use_case = RetrieveAllTripsForStopUseCase::new(Box::new(trip_repository_http_impl));

    use_case
        .execute(stop_hash)
        .map_ok(|t| t.iter().map(TripModel::from_entity).collect())
        .await
}

#[derive(Debug)]
pub struct TripModel {
    pub id: String,
    pub line_number: String,
    pub line_name: String,
    pub departures: Vec<DepartureModel>,
}

impl TripModel {
    fn from_entity(entity: &Trip) -> Self {
        Self {
            id: entity.id.clone(),
            line_number: entity.line_number.clone(),
            line_name: entity.line_name.clone(),
            departures: entity
                .departures
                .iter()
                .map(DepartureModel::from_entity)
                .collect(),
        }
    }
}

#[derive(Debug)]
pub struct DepartureModel {
    pub id: String,
    pub time: String,
    pub is_next_day: bool,
    pub is_time_based_on_gps: bool,
}

impl DepartureModel {
    fn from_entity(entity: &Departure) -> Self {
        Self {
            id: entity.id.clone(),
            time: entity.time.clone(),
            is_next_day: entity.is_next_day,
            is_time_based_on_gps: entity.is_time_based_on_gps,
        }
    }
}
