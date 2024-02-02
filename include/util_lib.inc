;-------------------------------------------------------------------------------
; Predefined Delay constants for util_delay function
;-------------------------------------------------------------------------------
   
#define  DELAY_200uS     16    
#define  DELAY_500uS     41    
#define  DELAY_1MS       83    
#define  DELAY_2MS      166
#define  DELAY_5MS      415
#define  DELAY_10MS     830
#define  DELAY_20MS    1660
#define  DELAY_50MS    4150
#define  DELAY_100MS   8300
#define  DELAY_200MS  16600
#define  DELAY_500MS  41500


;-------------------------------------------------------------------------------
; Library Utility routines
;-------------------------------------------------------------------------------

            extrn   util_full_mult16
            extrn   util_write_10x
            extrn   util_c_to_f
            extrn   util_delay
            extrn   util_wait
            extrn   util_debug
