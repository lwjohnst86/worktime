`%>%` <- magrittr::`%>%`
utils::globalVariables(".")

extract_header <- function(x, pattern) {
    ifelse(grepl(pattern = pattern, x), x, NA)
}

count_header_level <- function(x) {
    nchar(as.character(x)) - nchar(gsub("\\*", "", x))
}

import_clock_org <- function(file) {
    org_file <- readr::read_lines(file)

    headlines_string <- "^\\*+\\s.*"
    timestamps_string <- "CLOCK: "

    tasks_times_df <- org_file %>%
        dplyr::as_data_frame() %>%
        dplyr::filter_at("value",
                      dplyr::all_vars(grepl(headlines_string, .) |
                                      grepl(timestamps_string, .)))

    smallest_headline <- max(count_header_level(tasks_times_df$value))
    if (smallest_headline > 4) {
        warning("Any headlines below the fourth are not extracted.")
    }

    headlines_fixed_df <- tasks_times_df %>%
        dplyr::mutate_at(
            "value",
            dplyr::funs(
                AllHeaders = extract_header(., "^\\*+ "),
                Header1 = extract_header(., "^\\*{1} "),
                Header2 = extract_header(., "^\\*{2} "),
                Header3 = extract_header(., "^\\*{3} "),
                Header4 = extract_header(., "^\\*{4} ")
            )
        ) %>%
        tidyr::fill("Header1", "Header2", "Header3", "Header4") %>%
        dplyr::mutate_at(dplyr::vars(dplyr::starts_with("Header"), "value", "AllHeaders"),
                         dplyr::funs(gsub("\\*", "", .))) %>%
        dplyr::mutate_at("AllHeaders", dplyr::funs(ifelse(is.na(.), "", .))) %>%
        dplyr::filter_at("value", dplyr::any_vars(. != AllHeaders))

    timestamps_extracted_df <- headlines_fixed_df %>%
        tidyr::separate(col = "value",
                        into = c("ClockIn", "ClockOut"),
                        sep = "--") %>%
        dplyr::mutate_at(c("ClockIn", "ClockOut"),
                         dplyr::funs(trimws(gsub(
                             "(CLOCK\\: +|\\[|\\].*$)", "", .
                         )))) %>%
        dplyr::mutate_at(
            c("ClockIn", "ClockOut"),
            dplyr::funs(lubridate::parse_date_time),
            orders = "ymd a HM",
            tz = Sys.timezone()
        ) %>%
        dplyr::select(dplyr::starts_with("Header"), "ClockIn", "ClockOut")

    timestamps_extracted_df
}

#print(import_clock_org("clocking.org"))
