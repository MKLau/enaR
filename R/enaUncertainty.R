#' Produce a set of plausible network models
#'
#' Connects enaR to limSolve to apply Linear Inverse Modelling to
#' conduct an uncertainty analysis for Ecological Network
#' Analysis. Users supply an initial ecosystem model (in the enaR
#' format) and uncertainty informaiton (several ways of specifying),
#' and the function returns a list (length = "iter") of balanced
#' plausible instantiations of the model.  This has been used to
#' determine the 95% confidnece intervals for network analysis results
#' and to determine the statistical significance of selected
#' comaprisons (Hines et al. 2015, 2016).
#'
#' @param x a network object.  This includes all weighted flows into and out of each node.
#' @param type is a paramter to switch the kind of uncertainty analysis to complete: "percent", "sym", "asym".  The "percent" options explores the parameter space for all parameters by a fixed percentage.  The "sym" options let the user specify an amount to explore around each flow estimate (internal flows (F) and boundary flows (inputs, exports, respirations).  This option assuems that the possible deviation is symmetric around the original values.  The "asym" lets the user specify upper and lower limits for each flow value.
#' @param iter is the number of plausible models to sample (number of iterations of the sampling algorithm).  The default is 10000, which is often a sufficient sample size for Monte Carlo sampling.
#' @param p.err If the user selects the "percent" type, they must also specify the percent change with this parameter.
#' @param F.sym If the user selects the "sym" type, then this parameter specifies the 1/2 the symmetric parameter range for each internal flow.  This should be specified as a data frame in a sparse matrix format with columns identifying the starting node, the target node, and the change value (in same units as flows).
#' @param z.sym If the user selects the "sym" type, then this parameter specifies the 1/2 the symmetric parameter range for each input flow. This is specified as a data frame in a sparse matrix format with columns identifying the node number and the change value (in same units as flows).
#' @param y.sym If the user selects the "sym" type, then this parameter specifies the 1/2 the symmetric parameter range for each output flows.  This is specified as a data frame in a sparse matrix format with columns identifying the node number and the change value (in same units as flows).
#' @param e.sym If the user selects the "sym" type, then this parameter specifies the 1/2 the symmetric parameter range for each export flows.  This is specified as a data frame in a sparse matrix format with columns identifying the node number and the change value (in same units as flows).
#' @param r.sym If the user selects the "sym" type, then this parameter specifies the 1/2 the symmetric parameter range for each respiration flows.  This is specified as a data frame in a sparse matrix format with columns identifying the node number and the change value (in same units as flows).
#' @param F.bot If the user selects the "asym" type, then this data.frame specifies the minimum possible value for each internal flows.  This should be specified as a data frame in a sparse matrix format with columns identifying the starting node, the target node, and the change value (in same units as flows).
#' @param z.bot  If the user selects the "asym" type, then this data.frame specifies the minimum value for each non-zero model input.  This is specified as a data frame in a sparse matrix format with columns identifying the node number and minimum value (in same units as flows).
#' @param y.bot If the user selects the "asym" type, then this data.frame specifies the minimum value for each non-zero model output.  This is specified as a data frame in a sparse matrix format with columns identifying the node number and minimum value (in same units as flows).
#' @param e.bot If the user selects the "asym" type, then this data.frame specifies the minimum value for each non-zero model export.  This is specified as a data frame in a sparse matrix format with columns identifying the node number and minimum value (in same units as flows).
#' @param r.bot If the user selects the "asym" type, then this data.frame specifies the minimum value for each non-zero model respiration.  This is specified as a data frame in a sparse matrix format with columns identifying the node number and minimum value (in same units as flows).
#' @param F.top If the user selects the "asym" type, then this data.frame specifies the maximum possible value for each internal flows.  This should be specified as a data frame in a sparse matrix format with columns identifying the starting node, the target node, and the change value (in same units as flows).
#' @param z.top  If the user selects the "asym" type, then this data.frame specifies the maximum value for each non-zero model input.  This is specified as a data frame in a sparse matrix format with columns identifying the node number and maximum value (in same units as flows).
#' @param y.top If the user selects the "asym" type, then this data.frame specifies the maximum value for each non-zero model output.  This is specified as a data frame in a sparse matrix format with columns identifying the node number and maximum value (in same units as flows).
#' @param e.top If the user selects the "asym" type, then this data.frame specifies the maximum value for each non-zero model export.  This is specified as a data frame in a sparse matrix format with columns identifying the node number and maximum value (in same units as flows).
#' @param r.top If the user selects the "asym" type, then this data.frame specifies the maximum value for each non-zero model respiration.  This is specified as a data frame in a sparse matrix format with columns identifying the node number and maximum value (in same units as flows).
#' @return \item{plausible.models}{A length=iter list of the plausible models in the network data object format spcified for enaR}
#' @author David E. Hines
#' @references  Hines, D.E., J.A. Lisa, B. Song, C.R. Tobias, S.R. Borrett. 2015. Estimating the impacts of sea level rise on the coupling of estuarine nitrogen cycling processes through comparative network analysis. Marine Ecology Progress Series 524: 137-154.
#'
#' Hines, D.E, Singh, P., Borrett, S.R. 2016. Evaluating control of nutrient flow in an estuarine nitrogen cycle through comparative network analysis. Ecological Engineering 89:70-79. doi:10.1016/j.ecoleng.2016.01.009
#'
#' @examples
#'
#'rm(list = ls())
#' library(enaR)
#'
#' # === INPUT ===
#'
#' # load model for analysis
#' data(troModels)
#' m <- troModels[[6]] # cone sping model (Kay et al. 1989; from Tilly)
#'
#' # Set Uncertainty Analysis parameters
#' no.samples = 150 # the number of plausible models to return (number of samples); 
#'                  # 10,000 would be better.
#' f.error = 25   # flow parameters percent error to investigate
#'
#' # === ACTION ===
#'
#' # peform uncertainty analysis
#' m.uncertainty.list <- enaUncertainty(m,                     # original model
#'                                      type = "percent",      # type of uncertainty to use
#'                                     p.err = f.error,       # define percent error
#'                                      iter = no.samples )    # specify the number of samples
#'
#' # apply selected ENA
#' ns <- lapply(m.uncertainty.list, get.ns) # get ENA whole network statstics (metrics, indicators)
#' ns <- as.data.frame(do.call(rbind, ns))
#'
#' ns.original <- as.data.frame(get.ns(m))
#'
#' # === OUTPUT ===
#'
#' # lets see how the uncertainty in model flows changed the model inputs and total system throughflow.
#' opar <- par(las = 1, mfcol = c(2,1))
#' hist(ns$Boundary, col = "steelblue", border = "white", main = "Total Boundary Input")
#' abline(v = ns.original$Boundary, col = "orange", lwd = 2)
#' hist(ns$TST, col = "blue2", border = "white", main = "Total System ThroughFLOW")
#' abline(v = ns.original$TST, col = "orange", lwd = 2)
#' rm(opar)
#'
#' # Lets use the 95% CI to make statisitcal inferences about the
#' # hypothesized "dominance of indirect effects" (Higashi and Patten
#' # 1991, Salas and Borrett 2010, Borrett et al. 2016), and "network
#' # homogenization" (Fath and Patten 1999, Borrett and Salas 2010,
#' # Borrett et al. 2016)
#'
#' # find 95% confidence intervals
#' id.95ci <- quantile(ns$ID.F, probs = c(0.025, 0.975))
#' hmg.95ci <- quantile(ns$HMG.O, probs = c(0.025, 0.975))
#'
#' # barplot of the calculated values for the original model
#' opar <- par(las = 1)
#' bp <- barplot(c(ns.original$ID.F, ns.original$HMG.O),
#'           ylim = c(0,3),
#'           col = "grey",
#'               border = NA,
#'               names.arg = c("Indirect/Direct", "Homogenization"))
#' abline(h = 1, col = "orange", lwd = 1.5) # threshold value
#'
#' # add 95CI error bars from Uncertainty Analysis
#'arrows(bp, c(id.95ci[1], hmg.95ci[1]),
#'       bp, c(id.95ci[2], hmg.95ci[2]),
#'       code = 3, lwd = 1.5, angle = 90, length = 0.2, col = "black")
#'
#' # === OUTPUT ===
#'
#' # lets see how the uncertainty in model flows changed the model inputs and total system throughflow.
#' opar <- par(las = 1, mfcol = c(2,1))
#' hist(ns$Boundary, col = "steelblue", border = "white", main = "Total Boundary Input")
#' abline(v = ns.original$Boundary, col = "orange", lwd = 2)
#' hist(ns$TST, col = "blue2", border = "white", main = "Total System ThroughFLOW")
#' abline(v = ns.original$TST, col = "orange", lwd = 2)
#' rm(opar)
#'

#' # Lets use the 95% CI to make statisitcal inferences about the
#' # hypothesized "dominance of indirect effects" (Higashi and Patten
#' # 1991, Salas and Borrett 2010, Borrett et al. 2016), and "network
#' # homogenization" (Fath and Patten 1999, Borrett and Salas 2010,
#' # Borrett et al. 2016)

#'
#' # find 95% confidence intervals
#' id.95ci <- quantile(ns$ID.F, probs = c(0.025, 0.975))
#' hmg.95ci <- quantile(ns$HMG.O, probs = c(0.025, 0.975))
#'
# barplot of the calculated values for the original model
#' opar <- par(las = 1)
#' bp <- barplot(c(ns.original$ID.F, ns.original$HMG.O),
#'          ylim = c(0,3),
#'          col = "grey",
#'              border = NA,
#'              names.arg = c("Indirect/Direct", "Homogenization"))
#' abline(h = 1, col = "orange", lwd = 1.5) # threshold value
#'
#' # add 95CI error bars from Uncertainty Analysis
#' arrows(bp, c(id.95ci[1], hmg.95ci[1]),
#'        bp, c(id.95ci[2], hmg.95ci[2]),
#'        code = 3, lwd = 1.5, angle = 90, length = 0.2, col = "black")
#'
#' # The results show that the orignial value of the Indirect-to-Direct
#' # flows ratio is larger than one, indicating the "dominance of
#' # indirect effects"; however, the 95% confidence interval for this
#' # indicator with a 25% uniform uncertainty spans the threshold value
#' # of 1 (ranging from 0.9 to 1.16).  Thus, we are not confident that
#' # this parameter exceeds the interpretation threshold given this
#' # level of uncertainty.  In contast, the network homogenizaiton
#' # pameter exceeds the interpretation threshold of 1.0, and the 95% CI
#' # for our level of uncertainty suggests that we are confident that
#' # this interpretation is correct.
#'
#' hist(ns$TST, col = "blue")
#'
#' @import limSolve
#' @import network
#' @export enaUncertainty
enaUncertainty=function(x = 'network object', type="percent", iter=10000,
                        p.err=NA,
                        F.sym=NA, z.sym=NA, y.sym=NA, e.sym=NA, r.sym=NA,
                        F.bot=NA, z.bot=NA, y.bot=NA, e.bot=NA, r.bot=NA,
                        F.top=NA, z.top=NA, y.top=NA, e.top=NA, r.top=NA){
    ## D.E. Hines, April 2017

    # check data input - Part 1 ----------------
    # data input warnings
    if (class(x) != 'network'){
        return(warning('x is not a network class object'))} # check object class

    # check "type"
    if( ( type %in% c("percent", "sym", "asym") ) == FALSE){
        return(warning('type must be "percent", "sym", or "asym".'))
    }


   # ===  Main Action ===

   # initialize indices
   U = unpack(x)                                               # unpack network object
   fluxes = which(U$F!=0, arr.ind=TRUE)                        # identify internal fluxes (from,to)
   inputs = seq(from=1, to=length(U$z), by=1)                  # identify inputs
   outputs = seq(from=1, to=length(U$y), by=1)                 # identify outputs (respiration + exports)
   exports = seq(from=1, to=length(U$e), by=1)                 # identify exports
   respirations = seq(from=1, to=length(U$r), by=1)            # identify respirations
   living = U$living                                           # extract living vector
   storage = U$X                                               # extract storage or biomass
   vertex.names <- x%v%'vertex.names'                          # get vertex (node) names


   # Build required inputs to limSolve (E, F, G)
   E = matrix(0, nrow=x$gal$n,
       ncol=(nrow(fluxes)+length(inputs)+length(exports)+length(respirations))) # initialize E

   for(i in 1:length(U$z)){  ## environmental inputs
       E[i,i] = U$z[i]
   }

   for(i in 1:nrow(E)){	## export losses
       E[i,length(U$z)+exports[i]] = -U$e[i]
   }

   for(i in 1:nrow(E)){	## respiration losses
       E[i,length(U$z)+length(exports)+respirations[i]] = -U$r[i]
   }


   for(f in 1:nrow(fluxes)){	 ## internal node inputs
       E[fluxes[f,2],(length(U$z)+length(exports)+length(respirations)+f)] = U$F[fluxes[f,1],fluxes[f,2]]
   }

#   for(f in 1:nrow(fluxes)){	 ## internal node outputs
#       E[fluxes[f,1],(length(U$z)+length(exports)+length(respirations)+f)] = -U$F[fluxes[f,1],fluxes[f,2]]
#   }

    for(f in 1:nrow(fluxes)){	 ## internal node outputs
        if(fluxes[f,1] == fluxes[f,2]){
            E[fluxes[f,1],(length(U$z)+length(exports)+length(respirations)+f)] = 0
        }else{
            E[fluxes[f,1],(length(U$z)+length(exports)+length(respirations)+f)] = -U$F[fluxes[f,1],fluxes[f,2]]
        }
    }

   F = rep(0,x$gal$n) # create F

   G = rbind(diag(rep(1, ncol(E))), diag(rep(-1, ncol(E)))) # create G


   # Alternative ways to construct H (uncertainty) based on "type" = {"percent", "sym", "asym"}
   # ---------------------------------------------------------------------------------------------

   # initilize parameters
   lower.percent=0
   upper.percent=0

   # type = percent -------------------

   if(identical(type,"percent") == TRUE){ ## uniform error by percent

       if(is.na(p.err) == TRUE) {
           return(warning('missing p.err while type="percent"'))

       } else {
           if(p.err < 100 && p.err > 0){
               lower.percent = 1-(p.err/100)
               upper.percent = 1+(p.err/100)
           }else if(p.err >= 100){           # if p.err is given greater than 100, restrict flows to be positive
               lower.percent = 0.0001
               upper.percent = 1+(p.err/100)
           }else if(p.err == 0){             # this is here because xsample breaks with zero percent error
               lower.percent = 0.9999
               upper.percent = 1.0001
               warning('Zero error given, using 0.0001% error')}

           H = c(rep(lower.percent, ncol(E)),rep(-upper.percent, ncol(E)))	# create H

       }
   }

   # type = symmetric ----------------------------------------------------------------

   if(identical(type, "sym") == TRUE){ ## error by symmetric amount

       # --- Check Data Inputs ---
       if (any(is.na(F.sym)) == TRUE){
           return(warning('please provide symmetric uncertainty data for internal flows'))} else {

                                        # Check Boundary flow uncertainties
               if (any(is.na(z.sym)) == TRUE){
                   return(warning('please provide symmetric uncertainty data for model inputs'))
               }					      # check uncertainty data inputs

               if(sum(U$y)> 0 && ( (all(U$e == U$y) || all(U$r == U$y)) ||
                                      ( all(is.na(U$e)) && all(is.na(U$r) ) )) ){ # if TRUE implies that only y-output values are specified in the model
                   if( any(is.na(y.sym))  ){
                       return(warning('Uncertainty data must match the model data. \n Because your model only has output values (y), please specify your model output undertainty data using the output vector (y.sym)'))
                   }
               } else {
                   if( any(is.na(e.sym)) && any(is.na(r.sym)) ) {
                       return(warning('Exports or Respiration values are specified for your model. \n Uncertainty data for losses must match the model output specifications (y vs. exports and respirations).'))
                   }
               }
           }


           # convert sparse data to matrix and vector form to ensure order stays correct
       if(is.na(y.sym)[1] == FALSE){ # if y is given, fill in e and r
         if(sum(U$e)>0){
           e.sym = y.sym
           r.sym = data.frame(1,0)
         }else{
           e.sym = data.frame(1,0)
           r.sym = y.sym
         }
       }

       mat.size = length(inputs) # number of nodes
       # flow matrix uncertainty
       Fu.sym = matrix(0, nrow=mat.size, ncol=mat.size)
       for(i in 1:nrow(F.sym)){
           Fu.sym[F.sym[i,1],F.sym[i,2]] = F.sym[i,3]
       }

    # input flow uncertainty
       zu.sym = rep(0, mat.size)
       for(i in 1:nrow(z.sym)){
           zu.sym[z.sym[i,1]] = z.sym[i,2]
       }

    # output flow uncertainty (y) calculated as sum of exports (e) and respirations (r)

    # export flow uncertainty
       eu.sym=rep(0,mat.size)
       for(i in 1:nrow(e.sym)){
           eu.sym[e.sym[i,1]] = e.sym[i,2]
       }

    # respiration flow uncertainty
       ru.sym=rep(0,mat.size)
       for(i in 1:nrow(r.sym)){
           ru.sym[r.sym[i,1]] = r.sym[i,2]
       }

           # Construct H -----
    # use matrix and vector format to construct H
       for(h in 1:(length(U$z))){
           lower.percent[h] = ((U$z[h]-zu.sym[h])/U$z[h])
       }

       for(h in (length(U$z)+1):(length(U$z)+length(exports))){
           lower.percent[h] =
               ((U$e[h-length(U$z)] - eu.sym[h-length(U$z)]) / U$e[h-length(U$z)])
       }

       for(h in (length(U$z)+length(exports)+1):(length(U$z)+length(exports)+length(respirations))){
           lower.percent[h] = ((U$r[h-length(U$z)-length(exports)]-ru.sym[h-length(U$z)-length(exports)])/U$r[h-length(U$z)-length(exports)])
       }

       for(h in (length(U$z)+length(exports)+length(respirations)+1):(length(U$z)+length(exports)+length(respirations)+nrow(fluxes))){
           lower.percent[h] = ((U$F[fluxes[(h-length(U$z)-length(exports)-length(respirations)),1],fluxes[(h-length(U$z)-length(exports)-length(respirations)),2]]-
                                    Fu.sym[fluxes[(h-length(U$z)-length(exports)-length(respirations)),1],fluxes[(h-length(U$z)-length(exports)-length(respirations)),2]])/
                                   U$F[fluxes[(h-length(U$z)-length(exports)-length(respirations)),1],fluxes[(h-length(U$z)-length(exports)-length(respirations)),2]])
       }

       lower.percent[is.na(lower.percent)] = 0
       lower.percent[which(lower.percent < 0)] = 0.0001 # restrict values to be positive
#       lower.percent[is.infinite(lower.percent)] = 1

       # order of H = all z, all e, all r, f by fluxes
       # inputs
       for(h in 1:(length(U$z))){
           upper.percent[h] = ( (U$z[h] + zu.sym[h]) / U$z[h])
       }

       # exports
       for(h in (length(U$z)+1):(length(U$z) + length(exports))){
           upper.percent[h] = ((U$e[h - length(U$z)] + eu.sym[h-length(U$z)]) / U$e[h - length(U$z)])
       }

       # respirations
       for(h in (length(U$z)+length(exports)+1):(length(U$z) + length(exports) + length(respirations))){
           upper.percent[h] = ((U$r[h-length(U$z)-length(exports)]+ru.sym[h-length(U$z)-length(exports)]) / U$r[h-length(U$z)-length(exports)])
       }

       # internal flows
       for(h in (length(U$z)+length(exports)+length(respirations)+1):(length(U$z)+length(exports)+length(respirations)+nrow(fluxes))){
           upper.percent[h] = ((U$F[fluxes[(h-length(U$z)-length(exports)-length(respirations)),1],fluxes[(h-length(U$z)-length(exports)-length(respirations)),2]]+
                                    Fu.sym[fluxes[(h-length(U$z)-length(exports)-length(respirations)),1],fluxes[(h-length(U$z)-length(exports)-length(respirations)),2]])/
                                   U$F[fluxes[(h-length(U$z)-length(exports)-length(respirations)),1],fluxes[(h-length(U$z)-length(exports)-length(respirations)),2]])
       }

       upper.percent[is.na(upper.percent)] = 0
#       upper.percent[is.infinite(upper.percent)] = 100 # constrain infinite values to be 100%

       H=c(lower.percent,-upper.percent)
   }

# Asymmetric ---------------------------------------------------------
   if(identical(type,"asym") ==TRUE){ ## asymetrical error

      # --- Check Data Inputs ---
       if (is.na(F.bot)[1] == TRUE || is.na(F.top)[1] == TRUE){
           return(warning('please provide top and bottom uncertainty data for internal flows'))} else {

                                        # Check Boundary flow uncertainties
               if (is.na(z.bot)[1] == TRUE || is.na(z.top)[1] == TRUE ){
                   return(warning('please provide top and bottom uncertainty data for model inputs'))
               }					      # check uncertainty data inputs

               if(sum(U$y)> 0 && ( (all(U$e == U$y) || all(U$r == U$y)) ||
                                      ( all(is.na(U$e)) && all(is.na(U$r) ) )) ){ # if TRUE implies that only y-output values are specified in the model
                   if( any(is.na(y.top)) ||  any(is.na(y.bot)) ){
                       return(warning('Uncertainty data must match the model data. \n Because your model only has output values (y), please specify your model output undertainty data using the output vector (y)'))
                   }
               } else {
                   if( any(is.na(e.top)) && any(is.na(e.bot)) && any(is.na(r.top)) && any(is.na(r.bot)) ) {
                       return(warning('Exports or Respiration values are specified for your model. \n Uncertainty data for losses must match the model output specifications (y vs. exports and respirations).'))
                   }
               }
           }


    # convert sparse data to matrix and vector form to ensure order stays correct
       if(is.na(y.top)[1] == FALSE){ # if y is given, fill in e and r
         if(sum(U$e)>0){
           e.top = y.top
           r.top = data.frame(1,0)
           e.bot = y.bot
           r.bot = data.frame(1,0)
         }else{
           e.top = data.frame(1,0)
           r.top = y.top
           e.bot = data.frame(1,0)
           r.bot = y.bot
         }
       }

       mat.size=length(inputs) # number of nodes
    # flow matrix uncertainty
       Fu.top=matrix(0, nrow=mat.size, ncol=mat.size)
       Fu.bot=matrix(0, nrow=mat.size, ncol=mat.size)
       for(i in 1:nrow(F.top)){
           Fu.top[F.top[i,1],F.top[i,2]]=F.top[i,3]
           Fu.bot[F.bot[i,1],F.bot[i,2]]=F.bot[i,3]
       }

    # input flow uncertainty
       zu.top=rep(0,mat.size)
       zu.bot=rep(0,mat.size)
       for(i in 1:nrow(z.top)){
           zu.top[z.top[i,1]]=z.top[i,2]
           zu.bot[z.bot[i,1]]=z.bot[i,2]
       }

    # output flow uncertainty (y) calculated as sum of exports (e) and respirations (r)

    # export flow uncertainty
       eu.top=rep(0,mat.size)
       eu.bot=rep(0,mat.size)
       for(i in 1:nrow(e.top)){
           eu.top[e.top[i,1]]=e.top[i,2]
           eu.bot[e.bot[i,1]]=e.bot[i,2]
       }

    # respiration flow uncertainty
       ru.top=rep(0,mat.size)
       ru.bot=rep(0,mat.size)
       for(i in 1:nrow(r.top)){
           ru.top[r.top[i,1]]=r.top[i,2]
           ru.bot[r.bot[i,1]]=r.bot[i,2]
       }

    # use matrix and vector format to construct H
       for(h in 1:(length(U$z))){
           lower.percent[h] = zu.bot[h]/U$z[h]
       }

       for(h in (length(U$z)+1):(length(U$z)+length(exports))){
           lower.percent[h] = eu.bot[h-length(U$z)]/U$e[h-length(U$z)]
       }

       for(h in (length(U$z)+length(exports)+1):(length(U$z)+length(exports)+length(respirations))){
           lower.percent[h] = ru.bot[h-length(U$z)-length(exports)]/U$r[h-length(U$z)-length(exports)]
       }

       for(h in (length(U$z)+length(exports)+length(respirations)+1):(length(U$z)+length(exports)+length(respirations)+nrow(fluxes))){
           lower.percent[h] = Fu.bot[fluxes[(h-length(U$z)-length(exports)-length(respirations)),1],fluxes[(h-length(U$z)-length(exports)-length(respirations)),2]]/
               U$F[fluxes[(h-length(U$z)-length(exports)-length(respirations)),1],fluxes[(h-length(U$z)-length(exports)-length(respirations)),2]]
       }

       lower.percent[is.na(lower.percent)] = 0
       lower.percent[which(lower.percent < 0)] = 0.0001 # restrict values to be positive

	  # order of H = all z, all e, all r, f by fluxes
       for(h in 1:(length(U$z))){
           upper.percent[h] = zu.top[h]/U$z[h]
       }

       for(h in (length(U$z)+1):(length(U$z)+length(exports))){
           upper.percent[h] = eu.top[h-length(U$z)]/U$e[h-length(U$z)]
       }

       for(h in (length(U$z)+length(exports)+1):(length(U$z)+length(exports)+length(respirations))){
           upper.percent[h] = ru.top[h-length(U$z)-length(exports)]/U$r[h-length(U$z)-length(exports)]
       }

       for(h in (length(U$z)+length(exports)+length(respirations)+1):(length(U$z)+length(exports)+length(respirations)+nrow(fluxes))){
           upper.percent[h] = Fu.top[fluxes[(h-length(U$z)-length(exports)-length(respirations)),1],fluxes[(h-length(U$z)-length(exports)-length(respirations)),2]]/
               U$F[fluxes[(h-length(U$z)-length(exports)-length(respirations)),1],fluxes[(h-length(U$z)-length(exports)-length(respirations)),2]]
       }

       upper.percent[is.na(upper.percent)] = 0

       H=c(lower.percent,-upper.percent)

   }


   # ===========================================================
   # --- UNCERTAINTY ANALYSIS --
   # Monte Carlo Model Sampling (using limSolve functions)
   # ===========================================================

   xs = limSolve::xsample(E=E, F=F, G=G, H=H, iter=iter)	# calculate plausible coefficients

   # ===========================================================
   # --- OUTPUT -- return plausible models to enaR --

   # initialize input objects for enaR
   z.ena = rep(0, x$gal$n)
   e.ena = rep(0, x$gal$n)
   r.ena = rep(0, x$gal$n)
   y.ena = rep(0, x$gal$n)
   F.ena = matrix(0, nrow=nrow(U$F), ncol=ncol(U$F))
   plausible.models = list()

   for(k in 1:nrow(xs$X)){		# for each set of plausible values (k)
       for(z in 1:length(U$z)){	# inputs (z)
           z.ena[z] = xs$X[k,z]*U$z[z]
       }
       for(e in (length(U$z)+1):(length(U$z)+length(U$e))){	# exports (e)
           e.ena[e-length(U$z)] = xs$X[k,e]*U$e[e-length(U$z)]
       }
       for(r in (length(U$z)+length(U$e)+1):(length(U$z)+length(U$e)+length(U$r))){	# respiration (r)
           r.ena[r-length(U$z)-length(U$e)] = xs$X[k,r]*U$r[r-length(U$z)-length(U$e)]
       }
       y.ena = e.ena+r.ena # calculate outputs (y) from sum of e and r
       for(f in (length(U$z)+length(U$e)+length(U$r)+1):ncol(xs$X)){								# internal fluxse (F)
           F.ena[fluxes[(f-length(U$z)-length(U$e)-length(U$r)),1], fluxes[(f-length(U$z)-length(U$e)-length(U$r)),2]] =
               xs$X[k,f]*U$F[fluxes[(f-length(U$z)-length(U$e)-length(U$r)),1],fluxes[(f-length(U$z)-length(U$e)-length(U$r)),2]]
       }

       rownames(F.ena) = vertex.names
       colnames(F.ena) = vertex.names

       plausible.models[[k]] = pack(flow = F.ena,
                           input = z.ena,
                           export = e.ena,
                           respiration = r.ena,
                           living = living,
                           output = y.ena,
                           storage = storage)
   }


   return(plausible.models)
}
