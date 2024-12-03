use async_trait::async_trait;

use crate::features::trips::domain::entities::trip::Trip;

#[async_trait]
pub trait TripRepository {
    async fn fetch_all_for_stop(&self, stop_hash: String) -> Result<Vec<Trip>, String>;
}
