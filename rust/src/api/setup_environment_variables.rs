use std::{collections::HashMap, env};

pub fn setup_environment_variables(map: HashMap<String, String>) -> Result<(), String> {
    map.iter().for_each(|(key, value)| env::set_var(key, value));

    Ok(())
}
