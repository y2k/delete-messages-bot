(ns delete-message-bot.core
  (:gen-class))

(def bot (com.pengrad.telegrambot.TelegramBot. (java.lang.System/getenv "TELEGRAM_TOKEN")))

(defn handle-update [updates]
  (doseq [x updates]
    (if (some? (.message x))
      (do
        (let [chat-id (.id (.chat (.message x)))]
          (if (some? (.newChatMembers (.message x)))
            (do
              (->>
               (.messageId (.message x))
               (com.pengrad.telegrambot.request.DeleteMessage. chat-id)
               (.toWebhookResponse)
               (println "\nDELETE: "))

              (->>
               (.messageId (.message x))
               (com.pengrad.telegrambot.request.DeleteMessage. chat-id)
               (.execute bot)
               (println "\nRESPONSE: ")))))))))

(defn -main [& args]
  (.setUpdatesListener
   bot
   (reify com.pengrad.telegrambot.UpdatesListener
     (process [_ updates]
       (try
         (handle-update updates)
         (catch Exception ex
           (.printStackTrace ex)))
       -1)))
  (println "Bot started"))
