import Foundation

/// Lightweight bilingual (English / Brazilian Portuguese) string layer for the
/// app's user-facing chrome.
///
/// This is intentionally NOT a full i18n stack: no NSLocalizedString, no
/// `.strings` resources, no third-party package. It is a single static table of
/// `key -> (en: String, pt: String)` pairs, selected by the persisted
/// `AppSettings.homeLanguage` value ("Portuguese" renders the PT column;
/// everything else — including nil/unknown — falls back to English).
///
/// Scope: UI chrome only — onboarding pages 2–4, main menu/module grid,
/// settings, paywall, dashboard/stat labels, tab labels. Vocabulary *content*
/// (actual words, translations, block names, sample words) is data and never
/// passes through this layer.
enum Localization {
    typealias Pair = (en: String, pt: String)

    /// The full chrome string table. `en` is always the safe fallback.
    /// Internal (not private) so the unit tests can validate every pair.
    static let table: [String: Pair] = [

        // MARK: - Onboarding (pages 2–4 + buttons). Direction picker cards are Phase A.

        "onboarding.modules.title": ("4 Learning Modules", "4 Módulos de Aprendizado"),
        "onboarding.modules.vocabulary": ("Build your word bank", "Monte seu banco de palavras"),
        "onboarding.modules.commonSentences": ("Learn everyday phrases", "Aprenda frases do dia a dia"),
        "onboarding.modules.pronunciation": ("Master your accent", "Aprimore seu sotaque"),
        "onboarding.modules.qa": ("Practice conversations", "Pratique conversas"),
        "onboarding.addWords.title": ("Start Adding Words", "Comece a Adicionar Palavras"),
        "onboarding.addWords.body": (
            "Tap the + button to add your first words. We'll auto-translate them for you!",
            "Toque no botão + para adicionar suas primeiras palavras. Nós as traduzimos automaticamente para você!"
        ),
        "onboarding.getStarted.title": ("You're All Set!", "Tudo Pronto!"),
        "onboarding.getStarted.body": (
            "Start learning %@ today. Your progress is saved locally and stays private.",
            "Comece a aprender %@ hoje. Seu progresso é salvo localmente e permanece privado."
        ),
        "onboarding.continue": ("Continue", "Continuar"),
        "onboarding.startLearning": ("Start Learning", "Começar a Aprender"),
        "onboarding.skip": ("Skip", "Pular"),
        "onboarding.tapToHear": ("Tap to hear it", "Toque para ouvir"),

        // Display-only language names (never used as machine values).
        "language.name.english": ("English", "Inglês"),
        "language.name.portuguese": ("Portuguese", "Português"),

        // MARK: - Module titles (shared across onboarding, menu, nav bars).

        "module.vocabulary": ("Vocabulary", "Vocabulário"),
        "module.commonSentences": ("Common Sentences", "Frases Comuns"),
        "module.pronunciation": ("Pronunciation", "Pronúncia"),
        "module.qa": ("Q&A", "P&R"),
        "module.comingSoon": ("COMING SOON", "EM BREVE"),
        "module.commonSentences.body": (
            "Learn everyday phrases and expressions to boost your conversational skills. Unlock this module when it's ready!",
            "Aprenda frases e expressões do dia a dia para turbinar suas habilidades de conversação. Desbloqueie este módulo quando ele estiver pronto!"
        ),
        "module.pronunciation.body": (
            "Practice speaking with real-time feedback and improve your accent. Unlock this module when it's ready!",
            "Pratique a fala com feedback em tempo real e melhore o seu sotaque. Desbloqueie este módulo quando ele estiver pronto!"
        ),
        "module.qa.body": (
            "Engage in interactive conversations and test your language knowledge. Unlock this module when it's ready!",
            "Participe de conversas interativas e teste seus conhecimentos do idioma. Desbloqueie este módulo quando ele estiver pronto!"
        ),

        // MARK: - Main menu / module grid.

        "menu.subtitle": ("Choose a module to start learning", "Escolha um módulo para começar a aprender"),
        "menu.tapToOpen": ("Tap to open", "Toque para abrir"),
        "menu.premiumLocked": ("Available with Langly Premium", "Disponível com o Langly Premium"),
        "menu.lockedMessage": (
            "Audio Mode is part of Langly Premium.\nSubscribe to unlock hands-free listening.",
            "O Modo Áudio faz parte do Langly Premium.\nAssine para desbloquear a escuta mãos livres."
        ),
        "menu.unlockPremium": ("Unlock with Langly Premium", "Desbloquear com o Langly Premium"),
        "menu.comingSoonMessage": (
            "This module is in development.\nLet us know you want it — we build what you ask for.",
            "Este módulo está em desenvolvimento.\nDiga que você o quer — nós criamos o que você pede."
        ),
        "menu.requestModule": ("Yes, I want this module released", "Sim, quero que este módulo seja lançado"),
        "menu.requestModuleMailBody": ("Yes I want this module to be released", "Sim, quero que este módulo seja lançado"),

        // MARK: - Paywall / subscription.

        "paywall.subtitle": ("Your commute is your classroom.", "Seu trajeto é a sua sala de aula."),
        "paywall.benefit.unlimited": ("Unlimited Audio Mode — loop until memorized", "Modo Áudio ilimitado — repita até memorizar"),
        "paywall.benefit.wordLists": ("Custom word lists with looping audio", "Listas de palavras personalizadas com áudio em loop"),
        "paywall.benefit.offline": ("Works 100% offline", "Funciona 100% offline"),
        "paywall.benefit.noAds": ("No ads", "Sem anúncios"),
        "paywall.subscribe": ("Subscribe for %@/month", "Assinar por %@/mês"),
        "paywall.restore": ("Restore Purchase", "Restaurar Compra"),
        "paywall.termsBody": (
            "The subscription renews automatically until cancelled. Payment is charged to your Apple ID account at confirmation of purchase.",
            "A assinatura renova automaticamente até ser cancelada. O pagamento é cobrado na sua conta Apple ID na confirmação da compra."
        ),
        "paywall.termsOfUse": ("Terms of Use", "Termos de Uso"),
        "paywall.privacy": ("Privacy", "Privacidade"),

        // MARK: - Settings.

        "settings.title": ("Settings", "Configurações"),
        "settings.done": ("Done", "Concluir"),
        "settings.languages": ("Languages", "Idiomas"),
        "settings.homeLanguage": ("Home Language (your language)", "Idioma Principal (seu idioma)"),
        "settings.targetLanguage": ("Language to Learn", "Idioma para Aprender"),
        "settings.audio": ("Audio Playback", "Reprodução de Áudio"),
        "settings.portugueseVoice": ("Portuguese Voice", "Voz em Português"),
        "settings.noVoiceFound": ("No Portuguese voice found", "Nenhuma voz em português encontrada"),
        "settings.gender.male": ("Male", "Masculina"),
        "settings.gender.female": ("Female", "Feminina"),
        "settings.gender.other": ("Other", "Outra"),
        "settings.voiceHint": (
            "Download higher-quality voices in Settings → Accessibility → Spoken Content → Voices",
            "Baixe vozes de maior qualidade em Ajustes → Acessibilidade → Conteúdo Falado → Vozes"
        ),
        "settings.playing": ("Playing...", "Reproduzindo..."),
        "settings.testVoice": ("Test Selected Voice", "Testar a Voz Selecionada"),
        "settings.silenceGap": ("Silence Gap Between Words", "Pausa Entre as Palavras"),
        "settings.loop": ("Continuous Loop", "Loop Contínuo"),
        "settings.loopDetail": ("Repeats the word list continuously", "Repete a lista de palavras continuamente"),
        "settings.appearance": ("Appearance", "Aparência"),
        "settings.darkMode": ("Dark Mode", "Modo Escuro"),
        "settings.darkModeDetail": ("Toggle between light and dark moss green", "Alterne entre verde-musgo claro e escuro"),
        "settings.about": ("About", "Sobre"),
        "settings.aboutBody": (
            "Your personal language learning assistant. Add the words you want to learn, practice with matching games, and memorize with audio repetition.",
            "Seu assistente pessoal de aprendizagem de idiomas. Adicione as palavras que quer aprender, pratique com jogos de associação e memorize com repetição de áudio."
        ),
        "settings.howTo": ("How to Use", "Como Usar"),
        "settings.howTo1": ("Tap a word block to start playing", "Toque em um bloco de palavras para começar a praticar"),
        "settings.howTo2": (
            "Create custom blocks — up to 150 words across 10 blocks",
            "Crie blocos personalizados — até 150 palavras em 10 blocos"
        ),
        "settings.howTo3": ("Play Mix N Match to lock in vocabulary", "Jogue Mix N Match para fixar o vocabulário"),
        "settings.howTo4": (
            "Use Audio Mode on your commute — audio repeats until memorized",
            "Use o Modo Áudio no trajeto — o áudio repete até memorizar"
        ),
        "settings.howTo5": (
            "Everything works offline — your data stays on your device",
            "Tudo funciona offline — seus dados ficam no seu dispositivo"
        ),
        "settings.howTo6": ("Need help? Email support@langly.app", "Precisa de ajuda? Envie um e-mail para support@langly.app"),
        "settings.support": ("Support: support@langly.app", "Suporte: support@langly.app"),
        "settings.saved": ("Settings Saved!", "Configurações Salvas!"),
        "settings.voiceQuality.premium": ("premium", "premium"),
        "settings.voiceQuality.enhanced": ("enhanced", "aprimorada"),
        "settings.voiceQuality.default": ("default", "padrão"),
        "settings.voiceQuality.compact": ("compact", "compacta"),

        // MARK: - Stats / dashboard.

        "stats.title": ("Your Stats", "Suas Estatísticas"),
        "stats.days": ("Days", "Dias"),
        "stats.words": ("Words", "Palavras"),
        "stats.games": ("Games", "Jogos"),
        "stats.audio": ("Audio", "Áudio"),
        "stats.streak": ("Streak", "Sequência"),
        "stats.mastered": ("Mastered", "Dominadas"),
        "stats.learning": ("Learning", "Aprendizado"),
        "stats.wordsAdded": ("Words Added", "Palavras Adicionadas"),
        "stats.wordsReviewed": ("Words Reviewed", "Palavras Revisadas"),
        "stats.wordsMastered": ("Words Mastered", "Palavras Dominadas"),
        "stats.masteryRate": ("Mastery Rate", "Taxa de Domínio"),
        "stats.engagement": ("Engagement", "Engajamento"),
        "stats.totalSessions": ("Total Sessions", "Total de Sessões"),
        "stats.totalTime": ("Total Time", "Tempo Total"),
        "stats.gamesPlayed": ("Games Played", "Jogos Jogados"),
        "stats.bestScore": ("Best Game Score", "Melhor Pontuação"),
        "stats.audioSessions": ("Audio Sessions", "Sessões de Áudio"),
        "stats.longestStreak": ("Longest Streak", "Maior Sequência"),
        "stats.daysValue": ("%d days", "%d dias"),
        "stats.whenYouPractice": ("When You Practice", "Quando Você Pratica"),
        "stats.peak": ("Peak: %@", "Pico: %@"),
        "stats.heatmapHint": ("Each cell = 1 hour of the day. Darker = more practice.", "Cada célula = 1 hora do dia. Mais escuro = mais prática."),
        "stats.trickyWords": ("Tricky Words", "Palavras Difíceis"),
        "stats.noErrors": (
            "No errors tracked yet. Play some games to see which words trip you up!",
            "Nenhum erro registrado ainda. Jogue algumas partidas para descobrir quais palavras te pegam!"
        ),
        "stats.errorsValue": ("%d errors", "%d erros"),
        "stats.noData": ("No data yet", "Nenhum dado ainda"),
        "stats.privacyTitle": ("100% Private", "100% Privado"),
        "stats.privacyBody": (
            "All data stays on your device. Nothing is sent anywhere.",
            "Todos os dados ficam no seu dispositivo. Nada é enviado a lugar algum."
        ),

        // MARK: - Vocabulary module screen (chrome only; words/blocks stay data).

        "vocab.mixNMatch.subtitle": (
            "Match English and Portuguese pairs before time runs out",
            "Associe pares em inglês e português antes que o tempo acabe"
        ),
        "vocab.mixAllBlocks": ("Mix All Blocks", "Misturar Todos os Blocos"),
        "vocab.mixAllBlocks.subtitle": (
            "Combine words from all blocks into one game",
            "Combine palavras de todos os blocos em uma partida"
        ),
        "vocab.audioMode": ("Audio Mode", "Modo Áudio"),
        "vocab.audioMode.subtitle": (
            "Listen on repeat, memorize, and speak out loud. Set repeats and gap in settings.",
            "Ouça em repetição, memorize e fale em voz alta. Defina repetições e pausa nas configurações."
        ),
        "vocab.addBlock": ("Add Word Block", "Adicionar Bloco de Palavras"),
        "vocab.addBlock.subtitle": ("Create a new block to organize your vocabulary", "Crie um novo bloco para organizar seu vocabulário"),
        "vocab.addBlockLocked": ("Unlock Unlimited Blocks", "Desbloqueie Blocos Ilimitados"),
        "vocab.addBlockLocked.subtitle": (
            "Go Premium to remove the 2-block free limit",
            "Assine o Premium para remover o limite de 2 blocos grátis"
        ),
        "vocab.lockedToUnlock": ("Tap to unlock", "Toque para desbloquear"),
        "vocab.lockedEmpty": ("Locked — no words saved here yet", "Bloqueado — nenhuma palavra salva aqui ainda"),
        "vocab.ghostBlockLocked": ("Unlock With Premium", "Desbloqueie com o Premium"),
        "vocab.ghostBlockLocked.subtitle": (
            "Unlimited blocks, audio mode,\nand future modules",
            "Blocos ilimitados, modo áudio\ne módulos futuros"
        ),
        "vocab.blocks": ("Blocks", "Blocos"),
        "vocab.words": ("Words", "Palavras"),
        "vocab.mastered": ("Mastered", "Dominadas"),
        "vocab.emptyTitle": ("No word blocks yet", "Nenhum bloco de palavras ainda"),
        "vocab.emptyBody": (
            "Tap \"Add Word Block\" to create your first block,\nthen add words to start learning.",
            "Toque em \"Adicionar Bloco de Palavras\" para criar seu primeiro bloco\ne, depois, adicione palavras para começar a aprender."
        ),
        "vocab.wordsCount": ("%d/%d words", "%d/%d palavras"),
        "vocab.tapToView": ("Tap to view", "Toque para ver"),
        "vocab.tapToAddWords": ("Tap to add words", "Toque para adicionar palavras"),
        "vocab.ghostBlock": ("Add a New Block", "Adicionar um Novo Bloco"),
        "vocab.ghostBlock.subtitle": (
            "Create another block to organize\nyour growing vocabulary",
            "Crie outro bloco para organizar\nseu vocabulário em crescimento"
        ),
        "vocab.newBlockTitle": ("New Word Block", "Novo Bloco de Palavras"),
        "vocab.blockName": ("Block name", "Nome do bloco"),
        "vocab.cancel": ("Cancel", "Cancelar"),
        "vocab.create": ("Create", "Criar"),
        "vocab.newBlockMessage": (
            "Enter a name for the new word block (max 10 blocks).",
            "Digite um nome para o novo bloco de palavras (máximo 10 blocos)."
        ),
        "vocab.blockLimitTitle": ("Block limit reached", "Limite de blocos atingido"),
        "vocab.blockLimitMessage": ("Delete a block to create a new one.", "Exclua um bloco para criar um novo."),
        "vocab.deleteBlock": ("Delete Block", "Excluir Bloco"),
        "vocab.deleteBlockConfirm": ("Delete \"%@\"", "Excluir \"%@\""),
        "vocab.deleteBlockMessage": (
            "This will permanently delete this block and all its words.",
            "Isso excluirá permanentemente este bloco e todas as suas palavras."
        ),
        "vocab.ok": ("OK", "OK"),
    ]

    /// Returns the localized string for `key` given the user's home language.
    /// "Portuguese" selects the Brazilian Portuguese column; every other value
    /// (nil, "English", unknown) falls back to English. An unknown key returns
    /// the key itself so a missing table entry fails loudly instead of silently
    /// showing the wrong language.
    static func string(_ key: String, homeLanguage: String?) -> String {
        guard let pair = table[key] else { return key }
        return homeLanguage == "Portuguese" ? pair.pt : pair.en
    }
}