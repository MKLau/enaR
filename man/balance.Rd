% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/balance.R
\name{balance}
\alias{balance}
\title{Balance Flow Network Models}
\usage{
balance(x, method = c("AVG2", "AVG", "IO", "OI", "I", "O"), tol = 5)
}
\arguments{
\item{x}{A network object.}

\item{method}{Methods for model balancing, see Allesina and Bondavalli
(2003).}

\item{tol}{Percent error tolerance used in the steady state check prior to
balancing.}
}
\value{
Returns a network object with a balanced flow network model.
}
\description{
Applies the methods of Allesina and Bondavalli (2003) for balancing flow
network models.
}
\examples{



data(troModels)
balance(troModels[[6]])



}
\references{
Allesina, S., Bondavalli, C., 2003. Steady state of ecosystem
flow networks: a comparison between balancing procedures. Ecological
Modelling 165(2-3):231-239.
}
\seealso{
\code{\link{bal}}
}
\author{
Matthew K. Lau Stuart R. Borrett
}
