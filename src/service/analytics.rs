use crate::domain::Commit;

pub fn count_commits(commits: &[Commit]) -> usize {
    commits.len()
}

pub fn filter_by_year<'a>(commits: &'a [Commit], year: &str) -> Vec<&'a Commit> {
    commits
        .iter()
        .filter(|c| c.date.starts_with(year))
        .collect()
}
