% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/enaAll.R
\name{enaAll}
\alias{enaAll}
\title{Conduct All Major ENA}
\usage{
enaAll(x = "network object")
}
\arguments{
\item{x}{A network object.}
}
\value{
\item{ascendency}{enaAscendency} \item{control}{enaControl}
\item{environ}{enaEnviron} \item{flow}{enaFlow} \item{mti}{enaMTI}
\item{storage}{enaStorage} \item{structure}{enaStructure}
\item{utility}{enaUtility with eigen.check=FALSE}
}
\description{
Conducts all major ENA with default settings and returns the output as a
named list.
}
\examples{



data(troModels)
output = enaAll(troModels[[6]])
names(output)



}
\seealso{
\code{\link{enaAscendency},\link{enaControl},\link{enaEnviron},\link{enaFlow},\link{enaMTI},\link{enaStorage},\link{enaUtility}}
}
\author{
Matthew K. Lau Stuart R. Borrett
}
