#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Commit {
    pub hash: String,
    pub date: String,
    pub subject: String,
    pub email: String,
}

impl Commit {
    pub fn new(hash: String, date: String, subject: String, email: String) -> Self {
        Self {
            hash,
            date,
            subject,
            email,
        }
    }
}
