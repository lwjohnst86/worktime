
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
import_org_clock <- function(file) {
    org_file <- readr::read_lines(file)

    headlines_string <- "^\\*+\\s.*"
    timestamps_string <- "CLOCK: "

    tasks_times_df <- org_file %>%
        as_data_frame() %>%
        filter_at("value",
                      all_vars(grepl(headlines_string, .) |
                                      grepl(timestamps_string, .)))

    smallest_headline <- max(count_header_level(tasks_times_df$value))
    if (smallest_headline > 4) {
        warning("Any headlines below the fourth are not extracted.")
    }

    headlines_fixed_df <- tasks_times_df %>%
        mutate_at(
            "value",
            funs(
                AllHeaders = extract_header(., "^\\*+ "),
                Header1 = extract_header(., "^\\*{1} "),
                Header2 = extract_header(., "^\\*{2} "),
                Header3 = extract_header(., "^\\*{3} "),
                Header4 = extract_header(., "^\\*{4} ")
            )
        ) %>%
        fill("Header1", "Header2", "Header3", "Header4") %>%
        mutate_at(vars(starts_with("Header"), "value", "AllHeaders"),
                         funs(gsub("\\*", "", .))) %>%
        mutate_at("AllHeaders", funs(ifelse(is.na(.), "", .))) %>%
        filter_at("value", any_vars(. != AllHeaders))

    timestamps_extracted_df <- headlines_fixed_df %>%
        separate(col = "value",
                        into = c("ClockIn", "ClockOut"),
                        sep = "--") %>%
        mutate_at(c("ClockIn", "ClockOut"),
                         funs(trimws(gsub(
                             "(CLOCK\\: +|\\[|\\].*$)", "", .
                         )))) %>%
        mutate_at(
            c("ClockIn", "ClockOut"),
            funs(lubridate::parse_date_time),
            orders = "ymd a HM",
            tz = Sys.timezone()
        ) %>%
        select(starts_with("Header"), "ClockIn", "ClockOut")

    timestamps_extracted_df
}
