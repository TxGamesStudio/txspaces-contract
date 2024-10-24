mod constants;
mod store;
mod events;
mod utils;

mod systems {
    mod admin;
    mod user;
    mod game_actions;
}

mod models {
    mod random;
    mod burner;
    mod user_data;
    mod invitation_code;
    mod character;
    mod character_level;
    mod building_head_quarter;
    mod building_army;
}

#[cfg(test)]
mod tests {
    mod setup;
    mod test_user;
    mod test_game_actions;
}