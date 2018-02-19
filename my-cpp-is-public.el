

(defun my-cpp-find-class-name (end-pt)
  (interactive);; todo ignore comment
  (if  (re-search-forward
     "^[[:blank:]]*class[[:blank:]]+\\([[:word:]]+\\(:\\{2\\}[[:word:]]+\\)*\\)"
     end-pt t)
      (if (match-string 1)
          (match-string 1)
        (user-error "no class name found"))
    (user-error "no class name found")));; do not consider template now


(defun my-cpp-is-a-class ()
  (interactive)
  (if (not (char-equal (char-after (point)) ?{)) ;; should not happen
      (user-error "my-cpp-is-a-class: Abort! Internal error!  only works on {")) ;; todo: better error handling? do we have assertion?

  (save-excursion
   (let ((end-pt (point))
        class-name
        pt-class)
    ;; todo: ignore comment
    ;; todo: let search stops at  {}(); or class name
    (if (re-search-backward "^[[:blank:]]*class[[:blank:]]+[[:word:]]+"  (point-min) t)
        (progn
          (setq pt-class (point))
          (setq class-name 
                (concat (current-word) " " (my-cpp-find-class-name end-pt)))
          (goto-char pt-class)
          (if (re-search-forward "[{}();]" end-pt t)
              nil ;; not a class
            class-name)
          (concat class-name)) ;; return class name
      (progn
        (user-error "my-cpp-is-a-class: Abort! Not in a class."))))))




(defun my-cpp-is-public ()
  "return class name plus \"public\", \"private\", or \"proctected\" for the 
   position by the cursor to indicate the type of any member in that position"
  (interactive)

  (save-excursion
    ;;case 1 2 & 3 but not case 4
    (let ((class-begin nil)
          ;; todo use the (regexp-quote) to generate the pattern
          (pattern "^[[:blank:]]*\\(public\\|private\\|protected\\)[[:blank:]]*:\\|\\(\{\\|\}\\)")
          (type nil)
          (className nil)
          (found nil)
          (ignore 0)
          pattern-matched1  
          pattern-matched2
          result)

      (while (and (not found) (re-search-backward pattern (point-min) t))
        ;; pattern-matched1 is nil, public,private, or protected
        (setq pattern-matched1 (if (match-string 1) (match-string 1) ""))
        ;; pattern-matched2 is nil, {, or}
        (setq pattern-matched2 (if (match-string 2) (match-string 2) ""))

        (if (and (= ignore 0) (not type)
                 (string-match "public\\|protected\\|private" pattern-matched1))
            (setq type pattern-matched1)
          (if (string-match "\{" pattern-matched2)
              (progn

                (if (/= ignore 0) 
                    (setq ignore (- ignore 1)) ;; match } and ignore
                  ;; check if it is the class
                  (progn
                    (setq className (my-cpp-is-a-class)) ;; className may be nil
                    (if (and type (not className)) ;; assertion
                        (user-error
                         (concat "Abort! Found " type " in non-class")))))
                (if className ;;  className found, generate result
                    (progn
                      (setq found t)
                      (if type
                          (setq result (concat className " " type))
                        (setq result (concat className " private" ))))))
            (if (string-match  "\}" pattern-matched2)
                (setq ignore (+ ignore 1)))))) ;; ignore util it is matched

      (if (not result)
          (user-error "not in a class! Exit!")
        (message "%s" result)))))

;; first create a git project:
;; todo:
;; 0. comment
;; 1. handle preprocessor? does it matter?
;; 2. struct
;; 3. template ??
;; 4. some small todo in between the code 
