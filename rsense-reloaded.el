(require 'json)

;;adapt the response to company-mode

(defun get-completion-text-from-json (json-completion-item)
  (last (assoc 'qualified_name json-completion-item) 0)
  )

(defun get-rsense-completion-list-aux (i completions)
  (if (equal i (length completions))
      ()
    (let
        ((next-name (get-completion-text-from-json (elt completions i)))
         (queue (get-rsense-completion-list-aux (+ i 1) completions)))
      (cons next-name queue)
      )
    )
  )

(defun get-rsense-completion-list (completions)
  (get-rsense-completion-list-aux 0 completions)
  )

;;build the request to send to the server
(defun get-current-point-position (j)
  (list (cons 'row (line-number-at-pos)) (cons 'column j)
  )
  )

(defun remove-segment-from-string (start end)
  (concat (buffer-substring-no-properties (point-min) (1- start))
          (buffer-substring-no-properties (1+ end) (point-max))
          )
  )

(defun get-adapted-buffer-code ()
  (let 
      ((current_buffer_line_vector (vconcat (buffer-substring-no-properties (point) (line-beginning-position))))
       (max-lp (- (point) (line-beginning-position)))
       (min-lp 0))
    ;; For each special character (. :) we may adapt buffer content for the rsense server
    (loop for i from (1- max-lp) downto min-lp do
          (cond
           ((char-equal (elt current_buffer_line_vector i) ?.)
            (return
             (vector (remove-segment-from-string (+ i 2 (line-beginning-position)) (point))
              (get-current-point-position (+ i 2))))
            )
           ((= i min-lp) (list 'prout))
           )
          )
    )
  )

jhqfieahi.oerjf(get-adapted-buffer-code)

(defun build-rsense-request (project file code location)
  (let ((command_json (cons 'command "code_completion"))
        (project_json (cons 'project project))
        (file_json (cons 'file file))
        (code_json (cons 'code code))
        (location_json (cons 'location location)))        
    (concat  "curl -s -XPOST -H \"Content-Type: application/json\" -d '" (json-encode (list command_json project_json file_json code_json location_json))  "' http://127.0.0.1:47367" )
    )
  )

(defun rsense-completion ()
  (let* ((vector_adapted_buffer (get-adapted-buffer-code))
        (file buffer-file-name)
        (project buffer-file-name)
        (location (elt vector_adapted_buffer 1))
        (code (elt vector_adapted_buffer 0)))
    (get-rsense-completion-list
     (last
      (assoc 'completions
             (json-read-from-string 
              (shell-command-to-string
               (build-rsense-request project file code location))))
      0)
     )
    )
    )
;;(rsense-completion)


(defun company-rsense-backend (command &optional arg &rest ignored)
  (interactive (list 'interactive))

  (case command
    (interactive (company-begin-backend 'company-rsense-backend))
    (prefix (and (eq major-mode 'enh-ruby-mode)
                 (company-grab-symbol)))
    (candidates
     (remove-if-not
      (lambda (c) (string-prefix-p (concat arg) c))
     (rsense-completion)
        )
     )
    ))

(add-to-list 'company-backends 'company-rsense-backend)
