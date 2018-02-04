;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; check C++ class member is public, private, or proctected
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; idea: search backward, until `public:', `private:', `protected:', or beginning of the class, then judge it accordingly. This function will be working in a class definition, in the first version will not work in side of any `{}' in the class
g(defun my-cpp-is-public ()
  "return \"public\", \"private\", \"proctected\", or \"unknown\" for the 
   member  pointed by the cursor"
  (interactive)

  (save-excursion
    ;;case 1 2 & 3 but not case 4
    (let ((class-begin nil)
          (pattern "^[[:blank:]]*public[[:blank:]]*:\\|^[[:blank:]]*protected[[:blank:]]*:\\|^[[:blank:]]*private[[:blank:]]*:")

          (pattern-curly-parenthesis "\{\\|\}")
          (paren-stack ())
          (not-found t)
          (orig-pt (point)))
;; TODO: fetch class name
;  (re-search-backward pattern-curly-parenthesis nil t) ;test

      ;; search for class boundary first, then search the member type:
      (while (and not-found (re-search-backward pattern-curly-parenthesis nil t))
        ;;  (setq char-found (char-after))
        (if (char-equal (char-after) ?{) ; found "{"
            (if (and paren-stack (char-equal (car paren-stack) ?}))
                (progn                        ; match first in stack
                  (pop paren-stack)
                  (message "match parenthesis, pop stack"))
              (progn
                                        ; unmatched stack,
                ;; todo check if this is a class's {
                (message "Is class and jump out of loop") ; to-do class name? 
                (setq not-found nil)))
          (progn ; found: "}"
            (push ?} paren-stack)
            (message "push to { into stack and continue"))))
      
      (if not-found ;; no class in front error and exit
          (progn 
            ;; move back
            (user-error "%s" "error: no class definition found. Abort!")))
      
      (setq class-begin (point))
      ;; todo1 combine this with searching class head: bug: does not work on line 14
      (goto-char orig-pt)

      ;; todo: skip all the  public or private or protected inside of an inner class
      ;; todo: skip the public or private or protected in the inheritance relation in the definition of 
      (if (re-search-backward pattern class-begin t)
          (message "%s" (current-word))
        (message "%s" "private")) ;; use something different.
      
      )))
  ;; search for class 
  ;; x case 1, without {} except the one with class
  ;; x case 2, with non-sub-class {}, but outside of it
  ;; todo: case 3, with non-sub-class {}, but inside of it
  ;; x case 4, with class{ public:} and inside
  ;; case 5, with class{public:} and outside
  ;; case 6, {} in comment
  ;; case 7, class in comment
  ;; case 8, has class declaration: class abc;
  ;; case 9, has namespace does it matter?
;;;END;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; representing a character { use ?{, in emacs lisp a character is an integer
(characterp ?{)
(characterp 125)
(char-equal 123 ?{)

;; debug use edebug, it will ask for defun, 

;;; function maybe useful
(thing-at-point 'char t) ;; see help
(re-search-backward)
(re-search-backward REGEXP &optional BOUND NOERROR COUNT)


(search-backward-regexp "^\\sc*public\\sc*:" &optional BOUND NOERROR COUNT)
(search-backward-regexp REGEXP &optional BOUND NOERROR COUNT)

;; car cdr & cons

(car '(rose violet daisy buttercup)) ;; non-destructive
(cdr '(rose violet daisy buttercup)) ;; non-destructive
(nthcdr 2 '(rose violet daisy buttercup));; non-destructive
(cons 'buttercup ())
(cons 'violet '(daisy buttercup)) ;; attach to the first
(length '(daisy buttercup))

(nth 0 '(rose violet daisy buttercup)) 
(nth 1 '(rose violet daisy buttercup))
(nth -2 '(rose violet daisy buttercup)) ;; negative argument does not work

(setq animals '(antelope giraffe lion tiger))
(setcar  animals 'hipopotamas)  ;; will change the first in animals
animals
(nthcdr 1 animals)
(pop animals)

(setq domesticated-animals '(horse cow sheep goat))
(setcdr domesticated-animals '(cat dog)) ;;will change except the first one
domesticated-animals

;;macros pop and push works on variables
;; todo next
;; 1. Done. use "save-excursion" and "let" for the function
;; 2. decide whether an unmatched { belongs to a class or not:
;;;; a. stop searching at next {,},;," beginning of the buffer, class if not in comment. Anything else?
;;;; b. what structure with { can not be a class? namespace(shall not be in head file anyway, function definition, enum, anything else?)
;; 3. a
;; 4. get the class name (less important)
;; 5. let function understand struct as well
;; 6. bug: check is this works with class inside of class
;;;; a. skip all the  public or private or protected inside of an inner class
;;;; b. skip the public or private or protected in the inheritance relation in the definition of an inner class
;; todo handle template class definition
;; new strategy:
;;1. move the point to the right public/private/protected delcaration
;;;; a. ignore public etc in inner class, comments
;;;; b. still need to handle the case of unmatched {: is it the beginning of the class?
;2. search the the class starting from the above point
;;;; in the first step, what shall we do is to igore some public/
;; 3. key point when you meet a {, how can you tell it is the beginning of a class? give example 

;; 1. a. assuming the point is at {, b. suppose no comment no inner class no enumerate etc. c. when do we stop searching? :  {,},;, public[[:blank:]]*:, private[[:blank:]]*:, protected[[:blank:]]:, or "beginning of the buffer", (,),
;; d. then search back f or class: class followi
;; 2. another way:find key word class first, then search back if there is no such characters: {} () ; pretend there is no comment in between.
;; ignore preprocessor

;; deprecated
(defun my-cpp-find-class-name (end-pt)
  (interactive);; todo ignore comment
  (if (re-search-forward "^[[:blank:]]*class[[:blank:]]+[[:word:]]" end-pt t)
      (current-word)
    (user-error "no class name found")));; do not consider template now


(defun my-cpp-is-a-class ()
  (interactive)
  (if (not (char-equal (char-after (point)) ?{))
      (user-error "Abort! Internal error!  only works on {")) ;; todo: better error handling? 

  (save-excursion
   (let ((end-pt (point))
        class-name
        pt-class)
    ;; todo: ignore comment
    ;; todo: let search stops at  {}(); or class name
    (if (re-search-backward "^[[:blank:]]*class[[:blank:]]+[[:word:]]"  (point-min) t)
        (progn
          (setq pt-class (point))
          (setq class-name 
                (concat (current-word) " " (my-cpp-find-class-name end-pt)))
          (goto-char pt-class)
          (if (re-search-forward "[{}();]" end-pt t)
              nil ;; not a class
            class-name)) ;; return class name
      (progn
        (user-error "my-cpp-is-a-class: Abort! Not in a class."))))))



;; case of comment: recognize the comment: suppose the cursor is not in the comment: 1. there is a // in front of the position in the same line
;; 2. in the blackets /**/

;; search back, when get {, case 1. is class, done, search for {,}, public:, private:, protected:
;; whenever reach {, check the class, 
;; when reach {
;; sequence1.1 {, :  if is class,  return class name and private
;; sequence1.2 {, :  if is not a class, set a beginning and redo search
;; when reach }
;; sequence2.1 }, ... non} ..., { set ignore all of them, set current point as start and continue.if cannot match, error
;; when reach public: private: protected: remember the word found, find first unmatched {, if is a class, return class name and type if not, error


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





;; -1. test it extensively:

;; first create a git project:
;; todo:
;; 0. comment
;; 1. handle preprocessor
;; 2. struct
;; 3. template
;; 4. some small todo in between the code
