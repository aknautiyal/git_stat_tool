use git_stat_tool::service::analytics;

fn main() {
    println!("git_stat_tool scaffold is ready");
    println!("placeholder total commits: {}", analytics::count_commits(&[]));
}
