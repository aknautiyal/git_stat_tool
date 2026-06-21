use super::contribution::Contribution;

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct User {
    pub email: String,
    pub contributions: Vec<Contribution>,
}

impl User {
    pub fn new(email: String, contributions: Vec<Contribution>) -> Self {
        Self {
            email,
            contributions,
        }
    }
}
