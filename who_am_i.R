library(cli)
who_am_i <- function(name){
  cli::cli_text("👋 Hi, my name is {name}.")
  cli::cli_text("👀 I like #rstats and data visualization.")
  cli::cli_text("🌱 I'm learning about shiny app development, JavaScript, and Bayes stat.")
  cli::cli_text("📦 I'm currently working on R package development tools.")
  cli::cli_text("💞 I'd love to collaborate on #rstats packages for data science.")
  cli::cli_text("📫 Want to connect? Use the badges below...")
}
