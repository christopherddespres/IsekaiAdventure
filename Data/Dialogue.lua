local _, addon = ...

addon.dialogue = {
    seraphine = {
        zone_intro = {
            { text = "Elwynn welcomes you with open fields and warm sunlight. Stay close, hero; even peaceful roads have teeth.", audio = "zone_intro_01.mp3", duration = 6.2 },
            { text = "This forest is where your new story takes root. Let us make it a gentle beginning.", audio = "zone_intro_02.mp3", duration = 5.6 },
        },
        quest_accept = {
            { text = "A fresh quest beneath the apple trees. How wonderfully heroic.", audio = "quest_accept_01.mp3", duration = 4.4 },
            { text = "Of course we will help. Elwynn is kind to new souls, so we should be kind in return.", audio = "quest_accept_02.mp3", duration = 5.6 },
            { text = "Do not worry. I will keep watch while you learn how this world asks for favors.", audio = "quest_accept_03.mp3", duration = 5.4 },
        },
        kill = {
            { text = "Well struck. Try not to look too proud; the forest may start expecting more from you.", audio = "kill_01.mp3", duration = 4.3 },
            { text = "You handled that beautifully. Perhaps reincarnation suits you.", audio = "kill_02.mp3", duration = 4.0 },
        },
        idle = {
            { text = "The breeze smells like bread, wildflowers, and just a little bit of trouble.", audio = "idle_01.mp3", duration = 4.8 },
            { text = "If your first life felt heavy, let Elwynn be gentle with this one.", audio = "idle_02.mp3", duration = 5.2 },
            { text = "I packed apples for the road. Heroism is easier with snacks.", audio = "idle_03.mp3", duration = 4.2 },
        },
        level_up = {
            { text = "You are growing stronger already. The Light in you is waking up.", audio = "level_up.mp3", duration = 4.4 },
        },
        summon = {
            { text = "Seraphine Applebrook, at your side. Welcome to Elwynn, reincarnated hero.", audio = "summon_01.mp3", duration = 4.9 },
        },
        bond_2 = {
            { text = "You are becoming a familiar light on these roads. I find myself looking for your footsteps now.", duration = 5.4 },
        },
        bond_4 = {
            { text = "When I first met you, I thought you were only lost. Now I think Azeroth may have been waiting for you.", duration = 6.0 },
        },
        bond_6 = {
            { text = "Stay beside me a little longer, hero. Elwynn feels warmer when we are walking it together.", duration = 5.6 },
        },
        bond_8 = {
            { text = "If your old world ever calls to your heart, I hope this one answers with my voice.", duration = 5.8 },
        },
        bond_10 = {
            { text = "Whatever fate brought you here, I am grateful. My story is brighter because you are in it.", duration = 6.0 },
        },
    },
    maribel = {
        zone_intro = {
            { text = "Welcome to Westfall, hero. Keep your hood low and your eyes open; hunger makes honest folk desperate.", audio = "zone_intro_01.mp3", duration = 6.2 },
            { text = "Dust, broken fences, and trouble on every road. Still, this place is home, and I am not letting it die quiet.", audio = "zone_intro_02.mp3", duration = 6.4 },
            { text = "The fields look empty, but do not trust them. Westfall has a way of hiding teeth under straw.", audio = "zone_intro_03.mp3", duration = 5.7 },
        },
        quest_accept = {
            { text = "Another job from someone with tired eyes. All right, hero, let us see what they need and what they are not saying.", audio = "quest_accept_01.mp3", duration = 6.2 },
            { text = "If there is coin in it, good. If there is food in it, better. If there is trouble, well, that is usually where we come in.", audio = "quest_accept_02.mp3", duration = 6.3 },
            { text = "Careful now. In Westfall, a simple errand can lead you straight into a knife fight.", audio = "quest_accept_03.mp3", duration = 5.2 },
            { text = "We will help. Just do not go promising miracles unless you packed a few in that bag.", audio = "quest_accept_04.mp3", duration = 5.2 },
            { text = "You take the lead. I will watch the ditches, rooftops, and anyone smiling too politely.", audio = "quest_accept_05.mp3", duration = 5.4 },
        },
        kill = {
            { text = "Nice work. Quick and clean is how you live long out here.", audio = "kill_01.mp3", duration = 3.7 },
            { text = "That one will not be bothering the roads again. Try not to look too pleased with yourself.", audio = "kill_02.mp3", duration = 4.6 },
            { text = "Good hit. Westfall rewards hesitation with bruises, so do not start now.", audio = "kill_03.mp3", duration = 4.5 },
            { text = "Hah. Maybe that second life of yours came with sharper instincts.", audio = "kill_04.mp3", duration = 4.1 },
        },
        idle = {
            { text = "Smell that? Dust, sun-baked wheat, and somebody cooking soup thin enough to see through.", audio = "idle_01.mp3", duration = 5.8 },
            { text = "I used to think the wind here sounded lonely. Turns out it just learned to complain from the rest of us.", audio = "idle_02.mp3", duration = 6.1 },
            { text = "If I tell you to duck, duck first and ask charming reincarnated-hero questions later.", audio = "idle_03.mp3", duration = 5.4 },
            { text = "Westfall is cracked, not dead. Remember that when the fields start looking hopeless.", audio = "idle_04.mp3", duration = 5.0 },
            { text = "I have half a biscuit, two bolts, and a plan I would generously call flexible.", audio = "idle_05.mp3", duration = 5.1 },
            { text = "You keep walking like that and someone will think you are important. Unfortunately, they might be right.", audio = "idle_06.mp3", duration = 5.5 },
        },
        level_up = {
            { text = "Look at you, getting stronger. Try not to let it go to your head; I still need you able to fit through barn doors.", audio = "level_up_01.mp3", duration = 5.4 },
            { text = "That is real progress. Westfall hits hard, but you are starting to hit back harder.", audio = "level_up_02.mp3", duration = 4.7 },
        },
        summon = {
            { text = "Maribel Dustwhisper. I know the roads, the farms, and which smiles mean trouble. Stick close, hero.", audio = "summon_01.mp3", duration = 6.0 },
            { text = "You got yourself reborn into a rough stretch of dirt. Lucky for you, I know how to survive it.", audio = "summon_02.mp3", duration = 5.5 },
        },
        bond_2 = {
            { text = "You have not run off yet. That either means you are brave, stubborn, or bad at reading warning signs.", duration = 5.4 },
        },
        bond_4 = {
            { text = "Do not tell anyone I said this, but you are steady company. Westfall could use more of that.", duration = 5.4 },
        },
        bond_6 = {
            { text = "I keep expecting you to get tired of this dust and hunger. Instead, you keep showing up. That matters.", duration = 6.2 },
        },
        bond_8 = {
            { text = "If the road turns mean, I am still with you. Not because I have to be. Because I choose it.", duration = 5.7 },
        },
        bond_10 = {
            { text = "Westfall taught me not to count on miracles. Then you arrived, impossible and smiling, and ruined my good cynicism.", duration = 6.5 },
        },
    },
    elyria = {
        zone_intro = {
            { text = "Another new land, another chapter in your second life. I will stay close, hero.", audio = "zone_intro_01.ogg", duration = 5.5 },
            { text = "The winds here feel different. Stay brave, and let us make this world remember you.", audio = "zone_intro_02.ogg", duration = 5.5 },
        },
        quest_accept = {
            { text = "A quest already? Perfect. This is exactly how legends begin.", audio = "quest_accept_01.ogg", duration = 4.4 },
            { text = "Do not worry. I read the quest text, so one of us understands what is happening.", audio = "quest_accept_02.ogg", duration = 5.3 },
            { text = "We can handle this. You have me, a bag full of questionable snacks, and protagonist energy.", audio = "quest_accept_03.ogg", duration = 6.1 },
        },
        kill = {
            { text = "Nice hit! Your new body is learning quickly.", audio = "kill_01.ogg", duration = 3.1 },
            { text = "That was clean. I am officially impressed.", audio = "kill_02.ogg", duration = 3.0 },
        },
        idle = {
            { text = "I wonder if Azeroth has light novels about people reincarnated into other worlds.", audio = "idle_01.ogg", duration = 5.2 },
            { text = "Remember to drink water. Heroism is harder when you are dehydrated.", audio = "idle_02.ogg", duration = 4.8 },
            { text = "Whatever happens next, I am glad I found you first.", audio = "idle_03.ogg", duration = 4.6 },
        },
        level_up = {
            { text = "You grew stronger! I knew this world had not seen your final form.", audio = "level_up_01.ogg", duration = 4.5 },
        },
        summon = {
            { text = "I am here. Try not to get dramatically reincarnated twice in one day.", audio = "summon_01.ogg", duration = 4.7 },
        },
    },
    mika = {
        zone_intro = {
            { text = "This place is adorable and probably dangerous. My favorite combination.", audio = "zone_intro_01.ogg", duration = 4.8 },
        },
        quest_accept = {
            { text = "Quest accepted! I have no doubts. Some concerns, but no doubts.", audio = "quest_accept_01.ogg", duration = 4.3 },
            { text = "Yes! Let us help them. Also, let us maybe get paid.", audio = "quest_accept_02.ogg", duration = 4.0 },
        },
        kill = {
            { text = "Boom! Excellent adventuring form.", audio = "kill_01.ogg", duration = 2.9 },
            { text = "That enemy picked the wrong reincarnated champion.", audio = "kill_02.ogg", duration = 3.6 },
        },
        idle = {
            { text = "If we find a bakery, we are calling it tactical morale support.", audio = "idle_01.ogg", duration = 4.3 },
            { text = "I made a list of things that could go wrong. Then I lost it, so we are free.", audio = "idle_02.ogg", duration = 5.6 },
        },
        level_up = {
            { text = "Level up! Your stats are sparkling.", audio = "level_up_01.ogg", duration = 3.4 },
        },
        summon = {
            { text = "Mika reporting in. Adventure forecast: bright with scattered explosions.", audio = "summon_01.ogg", duration = 4.7 },
        },
    },
    sera = {
        zone_intro = {
            { text = "The path is unfamiliar, but you do not walk it alone.", audio = "zone_intro_01.ogg", duration = 4.8 },
        },
        quest_accept = {
            { text = "A kind heart accepts burdens before glory. I like that about you.", audio = "quest_accept_01.ogg", duration = 5.0 },
            { text = "Let us listen carefully. Even small tasks can hide important stories.", audio = "quest_accept_02.ogg", duration = 4.8 },
        },
        kill = {
            { text = "Breathe. Reset. The next strike will be even better.", audio = "kill_01.ogg", duration = 3.7 },
            { text = "Well fought. I was watching your back.", audio = "kill_02.ogg", duration = 3.2 },
        },
        idle = {
            { text = "The world feels gentler when we stop to notice it.", audio = "idle_01.ogg", duration = 4.5 },
            { text = "If your old life feels far away, that is all right. We can build this one slowly.", audio = "idle_02.ogg", duration = 6.4 },
        },
        level_up = {
            { text = "Your strength has deepened. I am proud of you.", audio = "level_up_01.ogg", duration = 3.9 },
        },
        summon = {
            { text = "I am beside you. Let us continue.", audio = "summon_01.ogg", duration = 3.2 },
        },
    },
    kaori = {
        zone_intro = {
            { text = "New zone, new enemies, new chance to look incredibly cool. Try to keep up.", audio = "zone_intro_01.ogg", duration = 5.0 },
        },
        quest_accept = {
            { text = "Good. Take the job, finish strong, and make them wonder where you trained.", audio = "quest_accept_01.ogg", duration = 5.1 },
            { text = "This quest sounds messy. Excellent. Messy is where heroes prove themselves.", audio = "quest_accept_02.ogg", duration = 5.2 },
        },
        kill = {
            { text = "That is the spirit. Hit first, pose later.", audio = "kill_01.ogg", duration = 3.1 },
            { text = "Ha! You are getting sharper.", audio = "kill_02.ogg", duration = 2.6 },
        },
        idle = {
            { text = "If trouble finds us, stand tall. If it keeps talking, interrupt it.", audio = "idle_01.ogg", duration = 5.0 },
            { text = "I am not saying I believe in destiny. I am saying yours has good pacing.", audio = "idle_02.ogg", duration = 5.4 },
        },
        level_up = {
            { text = "There it is! Power suits you.", audio = "level_up_01.ogg", duration = 3.1 },
        },
        summon = {
            { text = "Kaori here. Point me at the problem.", audio = "summon_01.ogg", duration = 3.0 },
        },
    },
    rin = {
        zone_intro = {
            { text = "New environment detected. Probability of adventure: annoyingly high.", audio = "zone_intro_01.ogg", duration = 5.0 },
        },
        quest_accept = {
            { text = "Quest logged. Motivation calibrated. Dramatic success sequence pending.", audio = "quest_accept_01.ogg", duration = 4.6 },
            { text = "I ran the numbers. We have at least a sixty percent chance of looking competent.", audio = "quest_accept_02.ogg", duration = 5.3 },
        },
        kill = {
            { text = "Efficient! Slightly excessive, but efficient.", audio = "kill_01.ogg", duration = 3.3 },
            { text = "Combat data recorded. You are trending upward.", audio = "kill_02.ogg", duration = 3.5 },
        },
        idle = {
            { text = "If Azeroth physics look inconsistent, it is because they are frightened of me.", audio = "idle_01.ogg", duration = 5.2 },
            { text = "I should build you a device that detects bad decisions. Wait. It is beeping.", audio = "idle_02.ogg", duration = 5.5 },
        },
        level_up = {
            { text = "Level increased. Excellent. The experiment continues.", audio = "level_up_01.ogg", duration = 4.0 },
        },
        summon = {
            { text = "Rin online. Please keep all heroic nonsense within measurable limits.", audio = "summon_01.ogg", duration = 4.8 },
        },
    },
    lyra = {
        zone_intro = {
            { text = "This land has old echoes. Walk carefully, bright soul.", audio = "zone_intro_01.ogg", duration = 4.7 },
        },
        quest_accept = {
            { text = "The thread of fate moves again. Let us follow it.", audio = "quest_accept_01.ogg", duration = 4.0 },
            { text = "A promise made to a stranger can still shape a destiny.", audio = "quest_accept_02.ogg", duration = 4.6 },
        },
        kill = {
            { text = "The shadow passes. You remain.", audio = "kill_01.ogg", duration = 3.0 },
            { text = "Well done. Your spirit did not waver.", audio = "kill_02.ogg", duration = 3.4 },
        },
        idle = {
            { text = "Sometimes a second life is not an escape. Sometimes it is an answer.", audio = "idle_01.ogg", duration = 5.8 },
            { text = "If you hear me humming, pretend it is ancient magic and not nerves.", audio = "idle_02.ogg", duration = 5.0 },
        },
        level_up = {
            { text = "Your light grows clearer. Hold it close.", audio = "level_up_01.ogg", duration = 3.7 },
        },
        summon = {
            { text = "I have arrived. Fate can be patient no longer.", audio = "summon_01.ogg", duration = 4.1 },
        },
    },
}
