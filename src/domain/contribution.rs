use super::commit::Commit;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ContributionKind {
	Authored,
	Reviewed,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Contribution {
	pub kind: ContributionKind,
	pub commits: Vec<Commit>,
}

impl Contribution {
	pub fn new(kind: ContributionKind, commits: Vec<Commit>) -> Self {
		Self { kind, commits }
	}

	pub fn count(&self) -> usize {
		self.commits.len()
	}
}
