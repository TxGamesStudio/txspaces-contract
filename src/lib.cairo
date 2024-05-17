mod constants;
mod store;
mod events;

mod systems {
    mod user;
    mod game_actions;
}

mod models {
    mod user_data;
    mod character;
    mod character_level;
}

#[cfg(test)]
mod tests {
    mod setup;
    mod test_user;
    mod test_game_actions;
}