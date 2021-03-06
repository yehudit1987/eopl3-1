#lang eopl

(require test-engine/racket-tests)
;;;; Procedure Representation

;;; Env = Var -> SchemeVal

;; Extending the procedure representation to has another observer has-binding?
;; Method : each constructor should contain a list of method to indicate 
;;          different observer

;; empty-env : () -> Env
(define empty-env
  (lambda ()
    (list (lambda () #t)
          (lambda (search-var) #f)
          (lambda (search-var)
            (report-no-binding-found search-var)))))


;; extend-env : Var * SchemeVal * Env -> Env
(define extend-env
  (lambda (saved-var saved-val saved-env)
    (list (lambda () #f)
          (lambda (search-var)
            (if (eqv? search-var saved-var)
                #t
                ((cadr saved-env) search-var)))
          (lambda (search-var)
            (if (eqv? search-var saved-var)
                saved-val
                (apply-env saved-env search-var))))))


(check-expect (empty-env? (empty-env)) #t)
(check-expect (empty-env? (extend-env 'a 1 (empty-env))) #f)

;; empty-env : Env -> Bool
(define empty-env?
  (lambda (env)
    ((car env))))

(check-expect (has-binding? 'b (extend-env 'a 1 (empty-env))) #f)
(check-expect (has-binding? 'b (extend-env 'a 1 (extend-env 'b 2 (empty-env)))) #t)
;; has-binding? : Var * Env -> Bool
(define has-binding?
  (lambda (var env)
    ((cadr env) var)))

(check-error (apply-env (extend-env 'a 1 (empty-env)) 'c))
(check-expect (apply-env
               (extend-env 'a 1 (extend-env 'b 2 (empty-env))) 'b) 2)

;; apply-env : Env * Var -> SchemeVal
(define apply-env
  (lambda (env search-var)
    ((caddr env) search-var)))

(define report-no-binding-found
  (lambda (search-var)
    (eopl:error 'apply-env "No binding for ~s" search-var)))

(test)