
;;;======================================================
;;;   Monitoring Program
;;;
;;;     This program was introduced in Section 12.5.
;;;
;;;     CLIPS Version 6.0 Example
;;;
;;;     To execute, merely load, reset and run.
;;;======================================================

(defmodule MAIN (export ?ALL))

(deftemplate MAIN::device 
   (slot name (type SYMBOL))
   (slot status (allowed-values on off)))
  
(deffacts MAIN::device-information
  (device (name D1) (status on))
  (device (name D2) (status on))
  (device (name D3) (status on))
  (device (name D4) (status on)))

(deftemplate MAIN::sensor 
   (slot name (type SYMBOL)) 
   (slot device (type SYMBOL))
   (slot raw-value (type SYMBOL NUMBER)
                    (allowed-symbols none)
                    (default none))
   (slot state (allowed-values low-red-line 
                               low-guard-line
                               normal
                               high-red-line
                               high-guard-line)
                (default normal))
   (slot low-red-line (type NUMBER))
   (slot low-guard-line (type NUMBER))
   (slot high-guard-line (type NUMBER))
   (slot high-red-line (type NUMBER)))

(deffacts MAIN::sensor-information
  (sensor (name S1) (device D1)
          (low-red-line 60) (low-guard-line 70)
          (high-guard-line 120) (high-red-line 130))
  (sensor (name S2) (device D1)
          (low-red-line 20) (low-guard-line 40)
          (high-guard-line 160) (high-red-line 180))
  (sensor (name S3) (device D2)
          (low-red-line 60) (low-guard-line 70)
          (high-guard-line 120) (high-red-line 130))
  (sensor (name S4) (device D3)
          (low-red-line 60) (low-guard-line 70)
          (high-guard-line 120) (high-red-line 130))
  (sensor (name S5) (device D4)
          (low-red-line 65) (low-guard-line 70)
          (high-guard-line 120) (high-red-line 125))
  (sensor (name S6) (device D4)
          (low-red-line 110) (low-guard-line 115)
          (high-guard-line 125) (high-red-line 130)))

(deffacts MAIN::cycle-start
  (data-source [instance])
  (cycle 0))

(defrule MAIN::Begin-Next-Cycle
   ?f <- (cycle ?current-cycle)
   (exists (device (status on)))
   =>
   (retract ?f)
   (assert (cycle (+ ?current-cycle 1)))
   (focus INPUT TRENDS WARNINGS))

(defrule MAIN::End-Cycles
   (not (device (status on))) 
   =>
  (printout t "All devices are off" crlf)
  (printout t "Halting monitoring system" crlf)
  (halt))

(defmodule INPUT (import MAIN ?ALL))

(defclass INPUT::DATA-SOURCE
   (is-a USER))

(defmessage-handler INPUT::DATA-SOURCE get-data (?name)
  (printout t "Input value for sensor " ?name ": ")
  (read))

(defmessage-handler INPUT::DATA-SOURCE next-cycle (?cycle))

(definstances INPUT::user-data-source
   ([user] of DATA-SOURCE))

(defrule INPUT::Read-Sensor-Values-From-Sensors
  (data-source sensors)
  ?s <- (sensor (name ?name)
                (raw-value none)
                (device ?device))
  (device (name ?device) (status on))
  =>
  ;(modify ?s (raw-value (get-sensor-value ?name)))
  )

(defclass INPUT::INSTANCE-DATA-SOURCE
   (is-a DATA-SOURCE))

(defmessage-handler INPUT::INSTANCE-DATA-SOURCE get-data (?name)
   (bind ?sensor-data (instance-name (sym-cat ?name -DATA-SOURCE)))
   (if (not (instance-existp ?sensor-data)) 
      then (return FALSE))
   (bind ?data (send ?sensor-data get-data))
   (if (= (length$ ?data) 0)
      then  
      (printout t "No instance data for sensor " ?name crlf)
      (printout t "Halting monitoring system" crlf)
      (halt) 
      (return FALSE))
   (send ?sensor-data put-data (rest$ ?data))
   (nth$ 1 ?data))
   
(definstances INPUT::instance-data-source
   ([instance] of INSTANCE-DATA-SOURCE))

(deffacts local-cycle
   (local-cycle 0))
   
(defrule INPUT::next-cycle
  (cycle ?cycle)
  ?f <- (local-cycle ~?cycle)
  (data-source ?source)
  (object (is-a DATA-SOURCE) (name ?source))
  =>
  (send ?source next-cycle ?cycle)
  (retract ?f)
  (assert (local-cycle ?cycle)))
  
(defrule INPUT::Get-Sensor-Value-From-Data-Source
  (cycle ?cycle)
  (local-cycle ?cycle)
  (data-source ?source)
  (object (is-a DATA-SOURCE) (name ?source))
  ?s <- (sensor (name ?name) 
                (raw-value none) 
                (device ?device))
  (device (name ?device) (status on))
  =>
  (bind ?raw-value (send ?source get-data ?name))
  (if (not (numberp ?raw-value))
      then (halt)
      else (modify ?s (raw-value ?raw-value))))

(defclass INPUT::SENSOR-DATA 
   (is-a USER)
   (multislot data))

(definstances INPUT::sensor-instance-data-values 
  ([S1-DATA-SOURCE] of SENSOR-DATA
     (data 100 100 110 110 115 120))
  ([S2-DATA-SOURCE] of SENSOR-DATA
     (data 110 120 125 130 130 135))
  ([S3-DATA-SOURCE] of SENSOR-DATA
     (data 100 120 125 130 130 125))
  ([S4-DATA-SOURCE] of SENSOR-DATA
     (data 120 120 120 125 130 135))
  ([S5-DATA-SOURCE] of SENSOR-DATA
     (data 110 120 125 130 135 135))
  ([S6-DATA-SOURCE] of SENSOR-DATA
     (data 115 120 125 135 130 135)))

(defclass INPUT::FILE-DATA-SOURCE
   (is-a DATA-SOURCE)
   (slot file-logical-name (default FALSE))
   (multislot sensor)
   (multislot value))
   
(defmessage-handler INPUT::FILE-DATA-SOURCE get-data (?name)
  (if (not ?self:file-logical-name)
     then (send ?self get-file)))

(defmessage-handler INPUT::FILE-DATA-SOURCE get-file ()
  (bind ?logical-name (gensym*))
  (while TRUE
    (printout t "What is the name of the data file? ")
    (bind ?file-name (readline))
    (if (open ?file-name ?logical-name "r") 
       then
       (bind ?self:file-logical-name ?logical-name) 
       (return))))

(defrule INPUT::Read-Sensor-Values-From-File
  (data-source file)
  (data-file-open)
  (cycle ?time)
  =>
  (bind ?name (read data-file))
  (if (eq ?name EOF) then (halt))
  (while (and (neq ?name end-of-cycle)
              (neq ?name EOF))
     (bind ?raw-value (read data-file))
     (if (eq ?raw-value EOF) then (halt))
     (assert (raw-sensor-value ?name ?raw-value))
     (bind ?name (read data-file))
     (if (eq ?name EOF) then (halt))))

(defrule INPUT::Remove-Values-For-Inactive-Sensors
  (data-source file)
  (data-file-open)
  (cycle ?time)
  (sensor (name ?name) (device ?device))
  (device (name ?device) (status off))
  ?data <- (raw-sensor-value ?name ?raw-value)
  =>
  (retract ?data))

(defrule INPUT::Transfer-Sensor-Values-To-Sensors 
  (data-source file)
  ?s <- (sensor (name ?name) 
                (raw-value none)
                (device ?device))
  (device (name ?device) (status on))
  ?f <- (raw-sensor-value ?name ?raw-value)
  =>
  (modify ?s (raw-value ?raw-value))
  (retract ?f))

(defmodule TRENDS (import MAIN ?ALL))

(defrule TRENDS::Normal-State
  ?s <- (sensor (raw-value ?raw-value&~none)
                (low-guard-line ?lgl)
                (high-guard-line ?hgl))
  (test (and (> ?raw-value ?lgl) (< ?raw-value ?hgl)))
  =>
  (modify ?s (state normal) (raw-value none)))

(defrule TRENDS::High-Guard-Line-State
  ?s <- (sensor (raw-value ?raw-value&~none)
                (high-guard-line ?hgl)
                (high-red-line ?hrl))
  (test (and (>= ?raw-value ?hgl) (< ?raw-value ?hrl)))
  =>
  (modify ?s (state high-guard-line) (raw-value none)))
  
(defrule TRENDS::High-Red-Line-State
  ?s <- (sensor (raw-value ?raw-value&~none)
                (high-red-line ?hrl))
  (test (>= ?raw-value ?hrl))
  =>
  (modify ?s (state high-red-line) (raw-value none)))

(defrule TRENDS::Low-Guard-Line-State
  ?s <- (sensor (raw-value ?raw-value&~none)
                (low-guard-line ?lgl)
                (low-red-line ?lrl))
  (test (and (> ?raw-value ?lrl) (<= ?raw-value ?lgl)))
  =>
  (modify ?s (state low-guard-line) (raw-value none)))

(defrule TRENDS::Low-Red-Line-State
  ?s <- (sensor (raw-value ?raw-value&~none)
                (low-red-line ?lrl))
  (test (<= ?raw-value ?lrl))
  =>
  (modify ?s (state low-red-line) (raw-value none)))

(deftemplate MAIN::sensor-trend
   (slot name) 
   (slot state (default normal))
   (slot start (default 0)) 
   (slot end (default 0))
   (slot shutdown-duration (default 3)))

(deffacts MAIN::start-trends
  (sensor-trend (name S1) (shutdown-duration 3))
  (sensor-trend (name S2) (shutdown-duration 5))
  (sensor-trend (name S3) (shutdown-duration 4))
  (sensor-trend (name S4) (shutdown-duration 4))
  (sensor-trend (name S5) (shutdown-duration 4))
  (sensor-trend (name S6) (shutdown-duration 2)))

(defrule TRENDS::State-Has-Not-Changed
  (cycle ?time)
  ?trend <- (sensor-trend (name ?sensor) 
                          (state ?state)
                          (end ?end-cycle&~?time)) 
  (sensor (name ?sensor) (state ?state)
          (raw-value none))
  =>
  (modify ?trend (end ?time)))

(defrule TRENDS::State-Has-Changed
  (cycle ?time)
  ?trend <- (sensor-trend (name ?sensor) 
                          (state ?state)
                          (end ?end-cycle&~?time))
  (sensor (name ?sensor) 
          (state ?new-state&~?state)
          (raw-value none))
  =>
  (modify ?trend (start ?time) 
                 (end ?time) 
                 (state ?new-state)))

(defmodule WARNINGS (import MAIN ?ALL))

(defrule WARNINGS::Shutdown-In-Red-Region
  (cycle ?time)
  (sensor-trend 
     (name ?sensor) 
     (state ?state&high-red-line | low-red-line))
  (sensor (name ?sensor) (device ?device))
  ?on <- (device (name ?device) (status on))
  =>
  (printout t "Cycle " ?time " - ")
  (printout t "Sensor " ?sensor " in " ?state crlf)
  (printout t "   Shutting down device " ?device
              crlf)
  (modify ?on (status off)))
  
(defrule WARNINGS::Shutdown-In-Guard-Region
  (cycle ?time)
  (sensor-trend 
      (name ?sensor)
      (state ?state&high-guard-line | low-guard-line) 
      (shutdown-duration ?length)
      (start ?start) (end ?end))
  (test (>= (+ (- ?end ?start) 1)  ?length))
  (sensor (name ?sensor) (device ?device))
  ?on <- (device (name ?device) (status on))
  =>
  (printout t "Cycle " ?time " - ")
  (printout t "Sensor " ?sensor " in " ?state " ")
  (printout t "for " ?length " cycles "
              crlf) 
  (printout t "   Shutting down device " ?device
              crlf)
  (modify ?on (status off)))

(defrule WARNINGS::Sensor-In-Guard-Region
  (cycle ?time)
  (sensor-trend 
      (name ?sensor) 
      (state ?state&high-guard-line | low-guard-line)
      (shutdown-duration ?length)
      (start ?start) (end ?end))
  (test (< (+ (- ?end ?start) 1) ?length))
  =>
  (printout t "Cycle " ?time " - ")
  (printout t "Sensor " ?sensor " in " ?state crlf))
