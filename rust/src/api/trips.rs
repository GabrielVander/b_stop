use std::env;

use crate::features::trips::{
    data::repositories::trip_repository_http_impl::TripRepositoryHttpImpl,
    domain::{entities::trip::Trip, repositories::trip_repository::TripRepository},
};

pub async fn fetch_all_for_stop(stop_id: String) -> Result<Vec<Trip>, String> {
    let base_url: String = env::var("TRIPS_HTTTP_BASE_URL")
        .inspect_err(|e| log::error!("{e}"))
        .map_err(|_| "Missing environment variable 'TRIPS_HTTTP_BASE_URL'")?;
    let param_name: String = env::var("TRIPS_HASH_HTTP_QUERY_PARAM_NAME")
        .inspect_err(|e| log::error!("{e}"))
        .map_err(|_| "Missing environment variable 'TRIPS_HASH_HTTP_QUERY_PARAM_NAME'")?;

    let trip_repository_http_impl: TripRepositoryHttpImpl =
        TripRepositoryHttpImpl::new(base_url, param_name);

    trip_repository_http_impl.fetch_all_for_stop(stop_id).await
}
