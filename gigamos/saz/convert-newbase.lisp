




(defun show-and-tell-type (symbol)
  (format t "~%~S IS A ~A" symbol
          (cond ((get symbol 'si:type-predicate)
                 'SPECIFIER)
                ((fboundp symbol)
                 (selectq (type-of (fsymeval symbol))
                   (cons 'MACRO)
                   (compiled-function 'FUNCTION)
                   (closure 'SPECIAL-FORM)))
                ((get symbol 'system:system-constant)
                 'CONSTANT)
                ((assq symbol si:*interpreter-declaration-type-alist*)
                 'DECLARATION)
                (t 'VARIABLE))))


(defun tester ()
  (progn
    (dolist (each '(unwind-protect      ;things that are fboundp: macros, functions, and special forms
                       make-package
                     defvar))
      (show-and-tell-type each))
    (dolist (each '(*package*           ;things that are boundp: constants and variables
                     boole-and
                     ))
      (show-and-tell-type each))
    (dolist (each '(short-float         ;specifiers and declarations (elements of si:*standard-system-type-specifiers*)
                    notinline))
      (show-and-tell-type each))))


(defun parse-pair (infile outfile)
  (do ((item (read infile nil) (read infile nil))
       (route (read infile nil) (read infile nil)))
      ((null route) '*done*)
      (print item outfile)
    (if (fixnump (print (first route)))
      (prin1-then-space (cons
                          (cond ((get item 'si:type-predicate) 'ts)     ;type specifier
                                ((fboundp item)
                                 (selectq (type-of (fsymeval item))
                                   (cons 'dm)           ;defined macro
                                   ((symbol compiled-function microcode-function) 'df)  ;defined function
                                   (closure 'sf)))              ;special form
                                ((get item 'system:system-constant)
                                 'sc)                   ;system constant
                                ((assq item si:*interpreter-declaration-type-alist*)
                                 'ds)                   ;declaration specifier
                                (t 'gv))                        ;global variable
                          route)
                        outfile)
      (prin1-then-space route outfile))))



(setq *myfile* "gl:valid.valid-code;newbase.text")
(setq *yourfile* "gl:valid.valid-code;output-newbase.text")

(defun do-it (&optional (*infile* *myfile*) (*outfile* *yourfile*))
  (with-open-file (infile *infile* :direction ':input)
    (with-open-file (outfile *outfile* :direction ':output)
      (when (eq (parse-pair infile outfile) '*done*)
           (return '*done*))))))
