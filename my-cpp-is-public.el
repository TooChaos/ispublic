
(defun my-cpp-find-class-name (end-pt)
  (interactive);; todo ignore comment
  (let ((pattern
   "^[[:blank:]]*class[[:blank:]]+\\([[:word:]_]+\\(:\\{2\\}[[:word:]_]+\\)*\\)"))
    (if (re-search-forward pattern end-pt t)
        (if (match-string 1)
            (match-string 1)
          (user-error "no class name found"))
      (user-error "no class name found"))));; do not consider template now


(defun my-cpp-is-a-class ()
  (interactive)
  (if (not (char-equal (char-after (point)) ?{)) ;; should not happen
      (user-error "my-cpp-is-a-class: Abort! Internal error!  only works on {")) ;; todo: better error handling? do we have assertion?

  (save-excursion
    (let ((end-pt (point))
          (class-name nil)
          pt-class
          (search-done nil)
          (not-a-class nil))
      ;; todo: ignore comment
      ;; todo: let search stops at  {}(); or class name
      (while (not search-done)
        (if (re-search-backward "^[[:blank:]]*class[[:blank:]]+[[:word:]_]+"  (point-min) t)
            (if (null (nth 8 (syntax-ppss)))
                (progn
                  (setq pt-class (point))
                  (setq class-name 
                        (concat (current-word) " "
                                (my-cpp-find-class-name end-pt)))
                  ;;                  (goto-char pt-class)
                  (setq search-done t)
                  (while (and class-name (re-search-forward "[{}();]" end-pt t))
                    (if (null (nth 8 (syntax-ppss)))
                        (setq class-name nil))))) ;; not a class
;;                  (user-error  (concat "test: " class-name))))) ;; test
;;                    class-name)))
          (setq search-done t)))
        class-name)))


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
          result
          (not-comment-or-string nil))

      (while (and (not found) (re-search-backward pattern (point-min) t))
        (setq not-comment-or-string (null (nth 8 (syntax-ppss))))
        ;; pattern-matched1 is nil, public,private, or protected
        (setq pattern-matched1 (if (match-string 1) (match-string 1) ""))
        ;; pattern-matched2 is nil, {, or}
        (setq pattern-matched2 (if (match-string 2) (match-string 2) ""))

        (if (and not-comment-or-string (= ignore 0) (not type)
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

