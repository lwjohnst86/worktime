
extract_header <- function(x, pattern) {
    ifelse(grepl(pattern = pattern, x), x, NA)
}

count_header_level <- function(x) {
    nchar(as.character(x)) - nchar(gsub("\\*", "", x))
}

#' Import clocking lines from .org files.
#'
#' @param file org file.
#'
#' @return Imported org file
#' @export
#'
#' @examples
#'
#' import_org_clock("tests/testthat/clocking.org")
#'
import_org_clock <- function(file) {
    org_file <- readr::read_lines(file)

    headlines_string <- rex::rex(
        start,
        some_of(rex::escape("*")),
        space,
        anything,
        end
    )
    timestamps_string <- "CLOCK: "

    tasks_times_df <- org_file %>%
        as_tibble() %>%
        filter_at("value", all_vars(grepl(headlines_string, .) |
                                        grepl(timestamps_string, .)))

    number_headers <- max(count_header_level(tasks_times_df$value))

    headlines_added_df <- tasks_times_df %>%
        mutate_at("value", list(AllHeaders = ~ extract_header(., "^\\*+ ")))

    headers_separated_df <-
        1:number_headers %>%
        purrr::map_dfc(~ extract_header(headlines_added_df$value, paste0("^\\*{", .x, "} ")) %>%
                           as_tibble() %>%
                           setNames(paste0("Header", .x))) %>%
        tidyr::fill(starts_with("Header")) %>%
        bind_cols(headlines_added_df)

    headers_merged_df <-
        headers_separated_df %>%
        mutate_all(~ trimws(gsub("\\*", "", .))) %>%
        mutate_at("AllHeaders", ~ ifelse(is.na(.), "", .)) %>%
        filter_at("value", any_vars(. != AllHeaders))

    timestamps_extracted_df <- headers_merged_df %>%
        tidyr::separate(col = "value",
                        into = c("ClockIn", "ClockOut"),
                        sep = "--") %>%
        mutate_at(c("ClockIn", "ClockOut"),
                         list(~ trimws(gsub(
                             "(CLOCK\\: +|\\[|\\].*$)", "", .
                         )))) %>%
        mutate_at(
            c("ClockIn", "ClockOut"),
            list(lubridate::parse_date_time),
            orders = "ymd a HM",
            tz = Sys.timezone()
        ) %>%
        select(starts_with("Header"), "ClockIn", "ClockOut")

    timestamps_extracted_df
}
