library(cli)
who_am_i <- function(name){
  cli::cli_text("👋 Hi, my name is {name}.")
  Sys.sleep(time = 1.5)
  cli::cli_text("👀 I like #rstats and data visualization.")
  Sys.sleep(time = 1.5)
  cli::cli_text("🌱 I'm learning about shiny app development, JavaScript, and Bayesian statistics.")
  Sys.sleep(time = 1.5)
  cli::cli_text("📦 I'm currently working on R package development tools.")
  Sys.sleep(time = 1.5)
  cli::cli_text("💞 I'd love to collaborate on #rstats packages for data science.")
  Sys.sleep(time = 1.5)
  cli::cli_text("📫 Want to connect? Use the badges below...")
}
who_am_i("Martin")
