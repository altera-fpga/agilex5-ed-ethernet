//# ######################################################################## 
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//# ######################################################################## 


package ms_tcam_pkg;


   function automatic integer mst_log2ceil;
      input integer val;
      integer i;
   begin
      i = 1;
      mst_log2ceil = 0;
      while (i < val)
         begin
         mst_log2ceil = mst_log2ceil + 1;
         i = i << 1;
         end
      if (val < 2)
         begin
         mst_log2ceil = 1;
         end
   end
   endfunction
   localparam    MAX_PKT_SIZE   = 4;
   localparam	PID_WIDTH      = 10;
   


   
   
endpackage




   