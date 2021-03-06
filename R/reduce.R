#' Reduce a list to a single value by iteratively applying a binary function.
#'
#' `reduce` combines from the left, `reduce_right` combines from
#' the right.
#'
#' @inheritParams map
#' @param .f A two-argument function. .x is the accumulating value.
#'   .y is the value in the list.
#' @param .init If supplied, will be used as the first value to start
#'   the accumulation, rather than using \code{x[[1]]}. This is useful if
#'   you want to ensure that `reduce` returns the correct value when
#'   `.x` is [is_empty()].
#' @export
#' @examples
#' 1:3 %>% reduce(`+`)
#' 1:10 %>% reduce(`*`)
#'
#' 5 %>%
#'   replicate(sample(10, 5), simplify = FALSE) %>%
#'   reduce(intersect)
#'
#' x <- list(c(0, 1), c(2, 3), c(4, 5))
#' x %>% reduce(c)
#' x %>% reduce_right(c)
#' # Equivalent to:
#' x %>% rev() %>% reduce(c)
#'
#' # Use init when you want reduce to return a consistent type when
#' # given an empty lists
#' list() %>% reduce(`+`)
#' list() %>% reduce(`+`, .init = 0)
reduce <- function(.x, .f, ..., .init) {
  .f <- as_function(.f, ...)

  f <- function(x, y) {
    .f(x, y, ...)
  }

  Reduce(f, .x, init = .init)
}

#' @export
#' @rdname reduce
reduce_right <- function(.x, .f, ..., .init) {
  .f <- as_function(.f, ...)

  # Note the order of arguments is switched
  f <- function(x, y) {
    .f(y, x, ...)
  }

  Reduce(f, .x, init = .init, right = TRUE)
}

#' Accumulate recursive folds across a list
#'
#' `accumulate` applies a function recursively over a list from the left, while
#' `accumulate_right` applies the function from the right. Unlike `reduce`
#' both functions keep the intermediate results.
#'
#' @inheritParams reduce
#' @export
#' @examples
#' 1:3 %>% accumulate(`+`)
#' 1:10 %>% accumulate_right(`*`)
#'
#' # From Haskell's scanl documentation
#' 1:10 %>% accumulate(max, .init = 5)
#'
#' # Understanding the arguments .x and .y when .f
#' # is a lambda function
#' # .x is the accumulating value
#' 1:10 %>% accumulate(~ .x)
#' # .y is element in the list
#' 1:10 %>% accumulate(~ .y)
#'
#' # Simulating stochastic processes with drift
#' \dontrun{
#' library(dplyr)
#' library(ggplot2)
#'
#' rerun(5, rnorm(100)) %>%
#'   set_names(paste0("sim", 1:5)) %>%
#'   map(~ accumulate(., ~ .05 + .x + .y)) %>%
#'   map_df(~ data_frame(value = .x, step = 1:100), .id = "simulation") %>%
#'   ggplot(aes(x = step, y = value)) +
#'     geom_line(aes(color = simulation)) +
#'     ggtitle("Simulations of a random walk with drift")
#' }
accumulate <- function(.x, .f, ..., .init) {
  .f <- as_function(.f, ...)

  f <- function(x, y) {
    .f(x, y, ...)
  }

  Reduce(f, .x, init = .init, accumulate = TRUE)
}

#' @export
#' @rdname accumulate
accumulate_right <- function(.x, .f, ..., .init) {
  .f <- as_function(.f, ...)

  # Note the order of arguments is switched
  f <- function(x, y) {
    .f(y, x, ...)
  }

  Reduce(f, .x, init = .init, right = TRUE, accumulate = TRUE)
}
