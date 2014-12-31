fexSDK
======

.. toctree::
   :maxdepth: 4

.. _fexc:

manual documentation fexc()
------
.. module:: fexSDK.src
.. class:: fexc

.. method:: fexc.coregister

coregister register face boxes to average face video location
 
  SYNTAX:
 
  self.coregister()
  self.coregister('ArgName1',ArgVale1, ... )
 
  coregister uses procrustes analysis to register a face box and the
  associated face landmarks to a standardized face in the current video.
 
  OPTIONAL ARGUMENTS:
 
  'steps' - a scalar value of 1 or 2 (default is 1). When it is set to 2,
   coregistration is done once for all data, then the error in the
   coregistration is used to infer false positives, and coregistration is
   done a second time using the average position of non false positives.
 
  'scaling' - true or false (default: true). Determines whether 'scaling'
   is used for coregistration.
 
  'reflection' - true or false (default: false). Determine whether
   argument 'reflection' is used for coregistration.
 
  'fp' - a truth value (default: false), which determine whether the error
   from coregistration will be used to identify false positive. This false
   alarm identification method can also be called using FALSEPOSITIVE.
 
  'threshold' - a scalar between 0 and Inf (default is 2.50). It indicates
   the number or standard deviation above the mean of the residual sum of
   square error of the coregistration. When threshold is set to a number
   larger than 0, this is used to identify false positive.
 
   NOTE that the 'threshold' option has an effect only when the number of
   steps is set to 2, or when 'fp' is set to true.
 
 
  coregister does not produce any output. Coregistration parameter can be
  used using self.GET('coreg').


automatic documentation fexc()
------------------------------
.. automodule:: fexSDK.src

.. autoclass:: fexc
    :show-inheritance:
    :members:

 


