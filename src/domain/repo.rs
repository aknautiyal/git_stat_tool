#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Repo {
    pub name: String,
    pub path: String,
}

impl Repo {
    pub fn new(name: String, path: String) -> Self {
        Self { name, path }
    }
}
