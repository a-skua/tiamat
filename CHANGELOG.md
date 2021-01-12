## 0.1.2-nullsafety
- change casl2 parser  
  Comments can now be identified correctly.
  ```
  MAIN	START			; comment
  ; initialize GR1
  	XOR	GR1,GR1
  ;	LAD	GR1,5
  	LAD	GR1,2,GR1	comment!
	RET
	END
  ```

## 0.1.1-nullsafety
- supported web

## 0.1.0-nullsafety

- first version.
