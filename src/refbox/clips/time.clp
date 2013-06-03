
;---------------------------------------------------------------------------
;  time.clp - time utils
;
;  Created: Sat Jun 16 15:45:57 2012 (Mexico City)
;  Copyright  2011-2012  Tim Niemueller [www.niemueller.de]
;             2011       SRI International
;             2011       RWTH Aachen University (KBSG)
;             2011       Carnegie Mellon University
;  Licensed under GPLv2+ license, cf. LICENSE file of cedar
;---------------------------------------------------------------------------

;(defmodule TIME-UTILS)

(defglobal
  ?*PRIORITY_TIME_RETRACT*    = -10000
)

; This assumes Fawkes-style time, i.e. sec and usec

(deffunction time-diff (?t1 ?t2)
  (bind ?sec  (- (nth$ 1 ?t1) (nth$ 1 ?t2)))
  (bind ?usec (- (nth$ 2 ?t1) (nth$ 2 ?t2)))
  (if (< ?usec 0)
      then (bind ?sec (- ?sec 1)) (bind ?usec (+ 1000000 ?usec)))
  ;(printout t "time-diff called: " ?t1 " - " ?t2 " = " (create$ ?sec ?usec) crlf)
  (return (create$ ?sec ?usec))
)

(deffunction time-diff-sec (?t1 ?t2)
  (bind ?td (time-diff ?t1 ?t2))
  (return (+ (float (nth$ 1 ?td)) (/ (float (nth$ 2 ?td)) 1000000.)))
)

(deffunction timeout (?now ?time ?timeout)
  (return (> (time-diff-sec ?now ?time) ?timeout))
)

(deffunction timeout-sec (?now ?time ?timeout)
  (return (> (- ?now ?time) ?timeout))
)

(deffunction time-from-sec (?t)
  (return (create$ (integer ?t) (integer (* (- ?t (integer ?t)) 1000000.))))
)

(deffunction time-sec-format (?time-sec)
  (bind ?hour (div ?time-sec 3600))
  (bind ?min  (div (- ?time-sec (* ?hour 3600)) 60))
  (bind ?sec  (- ?time-sec (* ?hour 3600) (* ?min 60)))
  (if (> ?hour 0)
   then
    (return (format nil "%02d:%02d:%02d" ?hour ?min ?sec))
   else
    (return (format nil "%02d:%02d" ?min ?sec))
  )
)

; Check if two time ranges overlap each other.
; The parameters are two time ranges start and end times respectively.
; The units do not matter as long as they are the same for all values.
(deffunction time-range-overlap (?r1-start ?r1-end ?r2-start ?r2-end)
  (return (or (and (>= ?r1-start ?r2-start) (<= ?r1-start ?r2-end))
	      (and (>= ?r1-end ?r2-start) (<= ?r1-end ?r2-end))))
)

; --- RULES - general housekeeping
(defrule retract-time
  (declare (salience ?*PRIORITY_TIME_RETRACT*))
  ?f <- (time $?)
  =>
  (retract ?f)
)
