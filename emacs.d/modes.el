;; All the load paths for the modes go here
(add-to-list 'load-path (concat packages-dir "/buffer-move"))
(add-to-list 'load-path (concat packages-dir "/rainbow-mode"))
(add-to-list 'load-path (concat packages-dir "/actionscript-mode"))
(add-to-list 'load-path (concat packages-dir "/markdown-mode"))
(add-to-list 'load-path (concat packages-dir "/haskell-mode"))
(add-to-list 'load-path (concat packages-dir "/haml-mode"))
(add-to-list 'load-path (concat packages-dir "/js2-mode"))
(add-to-list 'load-path (concat packages-dir "/puppet-mode"))
(add-to-list 'load-path (concat packages-dir "/scala-mode"))

;; Buffer move - A helper to move buffers around when using multiple
;; frames.
(require 'buffer-move)

;; rainbow mode - Highlights colors within a file, such as "#FF00FF"
;; or "rgba(1,2,3,0.5)"
(require 'rainbow-mode)

;; ActionScript mode
(autoload 'actionscript-mode "actionscript-mode" nil t)

;; Markdown mode
(autoload 'markdown-mode "markdown-mode" nil t)

;; Haskell mode
(load "haskell-site-file")
(add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)
(add-hook 'haskell-mode-hook 'turn-on-haskell-indentation)

;; HAML/SASS mode
(autoload 'haml-mode "haml-mode" nil t)
(autoload 'sass-mode "sass-mode" nil t)

;; Puppet mode
(autoload 'puppet-mode "puppet-mode" nil t)

;; Scala mode
(require 'scala-mode-auto)

;; js-mode (espresso)
;; Espresso mode has sane indenting so we use that.
(setq js-indent-level 2)

;; JS2-Mode
(autoload 'js2-mode "js2" nil t)
(setq js2-basic-offset 2)
(setq js2-cleanup-whitespace t)

;; Custom indentation function since JS2 indenting is terrible.
;; Uses js-mode's (espresso-mode) indentation semantics.
;;
;; Based on: http://mihai.bazon.net/projects/editing-javascript-with-emacs-js2-mode
;; (Thanks!)
(defun my-js2-indent-function ()
  (interactive)
  (save-restriction
    (widen)
    (let* ((inhibit-point-motion-hooks t)
           (parse-status (save-excursion (syntax-ppss (point-at-bol))))
           (offset (- (current-column) (current-indentation)))
           (indentation (js--proper-indentation parse-status))
           node)

      (save-excursion

        ;; I like to indent case and labels to half of the tab width
        (back-to-indentation)
        (if (looking-at "case\\s-")
            (setq indentation (+ indentation (/ js-indent-level 2))))

        ;; consecutive declarations in a var statement are nice if
        ;; properly aligned, i.e:
        ;;
        ;; var foo = "bar",
        ;;     bar = "foo";
        (setq node (js2-node-at-point))
        (when (and node
                   (= js2-NAME (js2-node-type node))
                   (= js2-VAR (js2-node-type (js2-node-parent node))))
          (setq indentation (+ 4 indentation))))

      (indent-line-to indentation)
      (when (> offset 0) (forward-char offset)))))

(defun my-js2-mode-hook ()
  (if (not (boundp 'js--proper-indentation))
      (progn (js-mode)
             (remove-hook 'js2-mode-hook 'my-js2-mode-hook)
             (js2-mode)
             (add-hook 'js2-mode-hook 'my-js2-mode-hook)))
  (set (make-local-variable 'indent-line-function) 'my-js2-indent-function)
  (define-key js2-mode-map [(return)] 'newline-and-indent)
  (define-key js2-mode-map [(backspace)] 'c-electric-backspace)
  (define-key js2-mode-map [(control d)] 'c-electric-delete-forward)
  (message "JS2 mode hook ran."))

;; Add the hook so this is all loaded when JS2-mode is loaded
(add-hook 'js2-mode-hook 'my-js2-mode-hook)

;; Indentation size for java
(setq c-basic-offset 2)