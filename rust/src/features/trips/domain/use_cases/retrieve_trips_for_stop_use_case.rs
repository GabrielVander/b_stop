use futures::TryFutureExt;

use crate::features::trips::domain::{
    entities::trip::Trip, repositories::trip_repository::TripRepository,
};

pub struct RetrieveAllTripsForStopUseCase {
    trip_repository: Box<dyn TripRepository + Send + Sync>,
}

impl RetrieveAllTripsForStopUseCase {
    pub fn new(trip_repository: Box<dyn TripRepository + Send + Sync>) -> Self {
        Self { trip_repository }
    }

    pub async fn execute(&self, stop_hash: String) -> Result<Vec<Trip>, String> {
        log::info!("Fetching all trips for stop {stop_hash}");

        self.trip_repository
            .fetch_all_for_stop(stop_hash)
            .inspect_err(|e| log::error!("{e}"))
            .map_err(|_| "Unable to fetch all trips for stop {stop_hash}".to_string())
            .await
    }
}
