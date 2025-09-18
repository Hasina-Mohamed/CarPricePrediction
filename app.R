library(shiny)
library(xgboost)
library(caret)

# --- Load bundle ---
bundle    <- readRDS("xgb_bundle.rds")
xgb_model <- bundle$model
dmy       <- bundle$dmy
col_order <- bundle$cols
template  <- bundle$template   # a valid row from training (for factor levels etc.)

fmt_money <- function(x) paste0("$", format(round(as.numeric(x), 2), big.mark=","))

ui <- fluidPage(
  titlePanel("Car Price Predictor (XGBoost)"),
  sidebarLayout(
    sidebarPanel(
      # Adjust min/max to match your training data span
      sliderInput("year", "Model Year", min = 2000, max = 2025, value = 2014, step = 1),
      numericInput("engine_size", "Engine Size (L)", value = 2.0, min = 0.5, step = 0.1),
      numericInput("weight", "Vehicle Weight (lbs)", value = 3500, min = 800, step = 10),
      selectInput("fuel_type", "Fuel Type", choices = levels(template$fuel_type)),
      selectInput("transmission", "Transmission", choices = levels(template$transmission)),
      numericInput("owners", "Number of Owners", value = 1, min = 0, step = 1),
      actionButton("predict", "Predict Price")
    ),
    mainPanel(
      h3("Predicted Price"),
      uiOutput("price_ui"),
      br(),
      tags$small(em("Tip: If you update training, re-save xgb_bundle.rds and redeploy.")),
      hr(),
      tags$details(
        tags$summary("Debug info (for you)"),
        verbatimTextOutput("debug_out")
      )
    )
  )
)

server <- function(input, output, session) {
  observeEvent(input$predict, {
    # Basic input guards
    req(input$engine_size > 0, input$weight > 0)
    
    # Start from a valid template row so all factor levels exist
    new_df <- template
    
    # Overwrite with UI inputs
    new_df$year        <- as.integer(input$year)
    new_df$engine_size <- as.numeric(input$engine_size)
    new_df$weight      <- as.numeric(input$weight)
    
    # Coerce factors using training levels; fall back to first level if mismatch
    lvl_fuel <- levels(template$fuel_type)
    new_df$fuel_type <- factor(
      if (input$fuel_type %in% lvl_fuel) input$fuel_type else lvl_fuel[1],
      levels = lvl_fuel
    )
    lvl_trans <- levels(template$transmission)
    new_df$transmission <- factor(
      if (input$transmission %in% lvl_trans) input$transmission else lvl_trans[1],
      levels = lvl_trans
    )
    
    if ("owners" %in% names(new_df)) new_df$owners <- as.integer(input$owners)
    
    # Encode + column align + predict
    res <- tryCatch({
      enc <- predict(dmy, newdata = new_df)
      enc <- data.frame(enc, check.names = FALSE)
      
      # Add any missing columns (0) and order exactly as training
      missing_cols <- setdiff(col_order, colnames(enc))
      if (length(missing_cols)) enc[missing_cols] <- 0
      enc <- enc[, col_order, drop = FALSE]
      
      pred <- predict(xgb_model, newdata = as.matrix(enc))
      list(ok = TRUE, pred = pred[1], enc_cols = colnames(enc), missing = missing_cols)
    }, error = function(e) list(ok = FALSE, err = e))
    
    if (!res$ok) {
      output$price_ui <- renderUI(
        tags$p(style="color:#c00;", "Prediction failed. Check column names/levels vs training bundle.")
      )
      output$debug_out <- renderPrint(res$err)
    } else {
      output$price_ui <- renderUI(
        tags$div(style="font-size:1.6em;font-weight:700;", fmt_money(res$pred))
      )
      output$debug_out <- renderPrint({
        list(
          input_row = new_df[ , c("year","engine_size","weight","fuel_type","transmission","owners")[c("year","engine_size","weight","fuel_type","transmission","owners") %in% names(new_df)]],
          missing_added = res$missing,
          first_10_cols = res$enc_cols[1:min(10, length(res$enc_cols))]
        )
      })
    }
  })
}

shinyApp(ui, server)
