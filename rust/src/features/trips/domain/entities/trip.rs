#[derive(Debug)]
pub struct Trip {
    pub id: String,
    pub line_number: String,
    pub line_name: String,
    pub departures: Vec<Departure>,
}

impl Trip {
    pub fn new(
        id: String,
        line_number: String,
        line_name: String,
        departures: Vec<Departure>,
    ) -> Self {
        Self {
            id,
            line_number,
            line_name,
            departures,
        }
    }
}

#[derive(Debug)]
pub struct Departure {
    pub id: String,
    pub time: String,
    pub is_next_day: bool,
    pub is_time_based_on_gps: bool,
}

impl Departure {
    pub fn new(id: String, time: String, is_next_day: bool, is_time_based_on_gps: bool) -> Self {
        Self {
            id,
            time,
            is_next_day,
            is_time_based_on_gps,
        }
    }
}
