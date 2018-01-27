
#' Add minutes worked between clocking in and out.
#'
#' @param .data Clocking data from `.org` file.
#'
#' @return Add a column of minutes worked.
#' @export
#'
add_minutes_worked <- function(.data) {
    .data %>%
        mutate(MinutesWorked = difftime(ClockOut, ClockIn, unit = "mins"))
}
