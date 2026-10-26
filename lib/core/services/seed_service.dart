import '../models/question_model.dart';
import '../models/template_model.dart';
import '../database/database_service.dart';

class SeedService {
  SeedService._();

  static Future<void> seedIfNeeded() async {
    final db = DatabaseService.instance;
    final questionCount = await db.getQuestionCount();
    if (questionCount == 0) {
      await db.insertQuestions(_generateQuestions());
    }

    final templates = await db.getAllTemplates();
    if (templates.isEmpty) {
      await db.insertTemplates(_generateTemplates());
    }
  }

  static List<HavenTemplate> _generateTemplates() {
    return [
      const HavenTemplate(
        id: 'tpl_profile',
        title: 'My Personal Profile',
        category: 'Personal',
        description: 'Core truths, working habits, and personal principles.',
        content: '''# Personal Profile

### Where I Am Now
- Current focus: 
- What is giving me energy: 
- What is draining my energy: 

### Core Invariants
- 1. 
- 2. 
- 3. 

### My Quiet Daily Rules
- Sleep & morning rhythm: 
- Work & attention blocks: 
- Boundaries I protect: ''',
      ),
      const HavenTemplate(
        id: 'tpl_people_remember',
        title: 'People I Want to Remember',
        category: 'People',
        description: 'The people who shaped who I am and what they taught me.',
        content: '''# People I Want to Remember

### Who They Are
- Name: 
- Relationship: 
- First memory or how we met: 

### What Stood Out
- A distinct phrase or habit of theirs: 
- How they made me feel: 

### The Lesson
- What I learned from them: 
- A memory I want to keep safe: ''',
      ),
      const HavenTemplate(
        id: 'tpl_conversation_keeping',
        title: 'A Conversation Worth Keeping',
        category: 'People',
        description: 'Dialogue, unexpected clarity, and shared reflections.',
        content: '''# A Conversation Worth Keeping

- Date & Setting: 
- Who was there: 

### The Core Exchange
- What we were discussing: 
- The line or insight that stopped me: 

### Why It Mattered
- What changed in my thinking: 
- What I do not want to forget: ''',
      ),
      const HavenTemplate(
        id: 'tpl_college_life',
        title: 'My College Life',
        category: 'College',
        description:
            'Semesters, courses, campus walks, and formative friendships.',
        content: '''# College Life

### The Term / Year
- Semester: 
- Main subjects & projects: 

### Daily Atmosphere
- The library corner or desk where I sat: 
- The walks between classes: 
- Late night discussions: 

### Reflections
- What surprised me about myself this term: 
- A realization about my future: ''',
      ),
      const HavenTemplate(
        id: 'tpl_school_days',
        title: 'My School Memories',
        category: 'School',
        description:
            'Teachers, playground quiet, milestones, and early lessons.',
        content: '''# My School Memories

- Grade / Age: 
- Teachers who paid attention: 

### Early Impressions
- The classroom sounds and morning bell: 
- What I was curious about back then: 
- Friendships from that season: 

### Looking Back
- How that child lives in me today: ''',
      ),
      const HavenTemplate(
        id: 'tpl_books_worth_remembering',
        title: 'Books Worth Remembering',
        category: 'Books & Movies',
        description:
            'Passages, impressions, and how a book altered your perspective.',
        content: '''# Books Worth Remembering

- Title & Author: 
- Finished on: 

### Core Thesis / Atmosphere
- The question at the center of the book: 
- Lines or quotes that resonated: 

### Personal Takeaway
- How this book shifted my perspective: 
- Who I would recommend this to: ''',
      ),
      const HavenTemplate(
        id: 'tpl_movies_stayed',
        title: 'Movies That Stayed With Me',
        category: 'Books & Movies',
        description: 'Cinematography, silence, themes, and lasting emotions.',
        content: '''# Movies That Stayed With Me

- Title & Director: 
- Watched on: 

### The Feeling
- A scene that lingered in my mind: 
- Tone, music, or silence: 

### The Resonance
- Why did this specific story touch me: ''',
      ),
      const HavenTemplate(
        id: 'tpl_daily_routine',
        title: 'Daily Routine & Rhythm',
        category: 'Routines',
        description:
            'Morning rituals, focused intervals, and evening wind-down.',
        content: '''# Daily Routine & Rhythm

### Morning Cadence
- First 30 minutes after waking: 
- Movement & stillness: 

### Focus Hours
- High cognitive priority tasks: 
- Break rhythm & offline walks: 

### Evening Wind-Down
- Screens off time: 
- Reflection & reading: ''',
      ),
      const HavenTemplate(
        id: 'tpl_learn',
        title: 'Things I Want to Learn',
        category: 'Interests',
        description: 'Curiosities, skills, crafts, and areas of deep study.',
        content: '''# Things I Want to Learn

### Topic / Craft
- What drew my curiosity here: 
- Best foundational resources (books, mentors, practice): 

### Practice Plan
- Next small tangible project: 
- Milestone for the month: ''',
      ),
      const HavenTemplate(
        id: 'tpl_life_memories',
        title: 'Important Life Memories',
        category: 'Personal',
        description: 'Turning points, crossroads, quiet breakthroughs, and seasons of change.',
        content: '''# Important Life Memories

- Year / Season: 
- Where I was: 

### What Happened
- The event or silent turning point: 
- The sensory details (light, weather, sounds): 

### How It Shaped Me
- Who I became because of that moment: ''',
      ),
      const HavenTemplate(
        id: 'tpl_my_goals',
        title: 'My Annual & Seasonal Goals',
        category: 'Ideas',
        description:
            'Calm, intentional direction rather than exhausting hustle.',
        content: '''# Seasonal Direction

### What I am Moving Toward
- Priority 1: 
- Priority 2: 

### What I am Saying No To
- Distractions to decline: 
- Pressures to discard: 

### Definition of Enough
- When I will know I have done enough: ''',
      ),
      const HavenTemplate(
        id: 'tpl_places_been',
        title: 'Places I Have Been',
        category: 'Personal',
        description:
            'Cities, rooms, landscapes, and the air of unfamiliar places.',
        content: '''# Places I Have Been

- Location: 
- When I visited: 

### The Sense of Place
- Smells, architecture, quiet alleys: 
- The people I met or observed: 
- A moment when I felt truly present: ''',
      ),
    ];
  }

  static List<Question> _generateQuestions() {
    final List<Question> questions = [];
    int counter = 1;

    void addQ(String text, String category, List<String> tags) {
      questions.add(
        Question(
          id: 'q_${counter.toString().padLeft(4, '0')}',
          text: text,
          category: category,
          tags: tags,
        ),
      );
      counter++;
    }

    // Daily & Gratitude
    addQ('What is something small that made today better?', 'General', [
      'gratitude',
      'daily',
    ]);
    addQ('What was the quietest moment of your day today?', 'General', [
      'reflection',
      'calm',
    ]);
    addQ(
      'What did you notice today that you usually walk right past?',
      'General',
      ['mindfulness'],
    );
    addQ(
      'What conversation brought you unexpected comfort recently?',
      'General',
      ['people', 'dialogue'],
    );
    addQ('What is one thing you can forgive yourself for today?', 'General', [
      'grace',
      'mind',
    ]);
    addQ('What did you do today simply because you wanted to?', 'General', [
      'freedom',
    ]);
    addQ(
      'Where did your mind wander when you had a free moment today?',
      'General',
      ['thoughts'],
    );
    addQ(
      'What task felt surprisingly light once you finally began?',
      'General',
      ['work', 'action'],
    );
    addQ('Who made your life slightly easier or kinder this week?', 'General', [
      'gratitude',
      'people',
    ]);
    addQ('What sound brought you stillness today?', 'General', ['senses']);

    // My Story (Formative, Childhood, Lessons)
    final storyPrompts = [
      'What is your earliest vivid memory from childhood?',
      'Which room from your childhood home do you remember most clearly?',
      'What was a song or piece of music that defined your teenage years?',
      'What is a belief you held passionately five years ago that you have quietly outgrown?',
      'What was a difficult season in your life that later revealed unexpected strength in you?',
      'What did your family dinner table feel like growing up?',
      'What was the first thing you ever built, wrote, or created that you felt proud of?',
      'What did solitude feel like when you were younger compared to now?',
      'What was a crossroads where you chose the harder path?',
      'What is an ordinary Saturday morning from your past that you would like to relive?',
      'What teacher or elder took you seriously when you doubted yourself?',
      'What did you dream of becoming before the world told you what was practical?',
      'What was the first time you realized your parents were just ordinary human beings?',
      'What tradition from your upbringing do you want to keep forever?',
      'What tradition from your upbringing have you deliberately let go?',
      'What is a compliment you received years ago that still stays with you?',
      'What was the greatest risk you took that turned out to be worth it?',
      'When did you first feel truly independent?',
      'What book or film reshaped how you looked at suffering or joy?',
      'What was a place where you always felt safe as a child?',
      'What is a personal mystery about yourself that you are still untangling?',
      'What part of your personality did you once try to hide?',
      'What is an accomplishment that nobody else applauded but meant the world to you?',
      'What did your bedroom look like when you were sixteen?',
      'How has your relationship with silence changed over time?',
      'What was a silent turning point that shifted the trajectory of your education or career?',
      'What is something you learned about love from observing the people around you?',
      'What is a physical scar you have, and what is the story behind it?',
      'What was the best summer of your life, and why?',
      'What is one story about yourself that you rarely tell anyone?',
      'What was the hardest goodbye you ever had to say?',
      'What did your grandparents teach you without saying a word?',
      'What was an apology you gave that required real courage?',
      'What was an apology you wished you had received but learned to live without?',
      'What hobby or obsession from your youth do you secretly still cherish?',
      'How did you handle failure the first time it knocked the wind out of you?',
      'What was a trip or journey that changed your inner compass?',
      'What did home mean to you ten years ago, and what does it mean now?',
      'What was a moment when you stood up for something even though your voice shook?',
      'What is a simple habit you picked up from someone who is no longer in your life?',
    ];
    for (final p in storyPrompts) {
      addQ(p, 'My Story', ['story', 'identity', 'history']);
    }

    // My People (Relationships, Mentors, Memories)
    final peoplePrompts = [
      'Who is someone in your life who always makes you feel unhurried?',
      'What friend knows the most honest version of you?',
      'Who taught you the value of listening rather than giving advice?',
      'What is a conversation with a stranger that you still remember vividly?',
      'Who is someone you admire for how they carry adversity?',
      'What person in your life has a laugh that instantly disarms a room?',
      'Who is a friend you haven’t spoken to in months, but could pick right back up with?',
      'What quality do you look for most in the people you let close to you?',
      'Who was someone who gave you an honest critique when you needed it most?',
      'What is a memory of sitting in comfortable silence with someone you love?',
      'Who is someone younger than you who inspired you recently?',
      'Who is someone older whose wisdom anchored you during confusion?',
      'What is something kind someone did for you that they probably forgot immediately?',
      'What relationship in your life has required the most patience to nurture?',
      'Who is someone who expanded your worldview through their background or culture?',
      'What does loyalty look like to you in daily practice?',
      'Who in your life would you call at 2:00 AM without hesitation?',
      'What is a piece of advice a friend gave you that saved you from regret?',
      'Who is someone whose presence feels like a calm harbor in a storm?',
      'What shared inside joke or unspoken code do you have with your closest friend?',
      'Who taught you how to cook, mend, or repair something with your hands?',
      'What person helped you discover a love for art, books, or ideas?',
      'Who is someone you miss, and what would you say to them today?',
      'How do you show care to people when words feel inadequate?',
      'Who is someone you initially misjudged, only to discover a deep warmth in them?',
      'What does healthy space and independence look like in your dearest relationships?',
      'Who is the most generous person you know, not with money, but with their attention?',
      'What is a memory of a meal shared with people you cherish?',
      'Who encouraged you when you felt like giving up on a creative project?',
      'What is one way you can show gratitude to someone in your circle this week?',
    ];
    for (final p in peoplePrompts) {
      addQ(p, 'My People', ['people', 'relationships', 'memories']);
    }

    // My Interests (Curiosity, Reading, Craft, Passions)
    final interestPrompts = [
      'What subject could you read about for hours without checking the clock?',
      'What is a craft or discipline where you find deep focus?',
      'What book has permanently changed how you observe human nature?',
      'What piece of art or music gives you goosebumps no matter how many times you experience it?',
      'What question about the universe or history fascinates you most?',
      'If you had six uninterrupted months to learn any skill, what would it be?',
      'What tool, notebook, or instrument do you enjoy holding in your hands?',
      'What is an obscure topic you know surprisingly much about?',
      'What kind of landscape brings you the deepest sense of peace?',
      'What physical activity makes you feel grounded in your body?',
      'What film director, author, or architect has an aesthetic that speaks to you?',
      'What is a question that science or philosophy hasn’t answered that you wonder about?',
      'What is your favorite word, and why do you love how it feels to speak or write it?',
      'What kind of puzzle, problem, or riddle brings you joy to solve?',
      'What is something you enjoy making from scratch?',
      'What museum, library, or historic street could you walk through repeatedly?',
      'What area of knowledge intimidates you, yet secretly draws you in?',
      'What style of typography, print, or paper do you naturally appreciate?',
      'What is an album you listen to from start to finish without skipping?',
      'What question are you currently trying to answer through your work or study?',
      'What is an antique or physical artifact you would love to own?',
      'What is an idea from another field that you applied to your own life?',
      'What kind of weather makes you feel most reflective and creative?',
      'What game or sport taught you something essential about grace or strategy?',
      'What is a podcast, essay, or documentary that made you reconsider a prior opinion?',
      'What is a recipe or flavor combination that reminds you of home?',
      'What is an author whose prose style you find deeply calming?',
      'What is an invention that you think humanity took for granted?',
      'What is a skill you have that feels almost meditative when practiced?',
      'What creative project are you quietly dreaming about starting?',
    ];
    for (final p in interestPrompts) {
      addQ(p, 'My Interests', ['interests', 'curiosity', 'craft']);
    }

    // My Future (Aspirations, Values, Horizons)
    final futurePrompts = [
      'What kind of person do you want to be when you are eighty years old?',
      'What is one boundary you need to protect more fiercely in the coming months?',
      'What does a truly successful life look like to you when stripped of prestige?',
      'What is an experience you want to have before the end of this decade?',
      'If you knew you could not fail, what creative leap would you take?',
      'What habit are you currently cultivating that your future self will thank you for?',
      'What is a project you want to finish that will outlive your daily worries?',
      'What kind of home environment do you hope to build for yourself in five years?',
      'What fear is currently whispering to you, and what is the calm truth against it?',
      'What does financial peace of mind mean to you specifically?',
      'What relationship in your life do you want to invest deeper attention into?',
      'What is a place on earth you have promised yourself you will visit?',
      'What is an old grudge or grievance that is time to finally set down?',
      'How do you want people to remember your hospitality and presence?',
      'What is a legacy of character—not wealth—that you wish to leave behind?',
      'What would your life look like if you cut your digital noise in half?',
      'What are three words you want to define your coming year?',
      'What skill will be essential for the kind of work you want to do in the future?',
      'What does rest look like when you aren’t running away from exhaustion?',
      'What is one thing you can say "no" to this month so you can say "yes" to your health?',
      'What kind of community or neighborhood do you hope to belong to?',
      'What is an adventure that frightens you just enough to know it matters?',
      'What do you hope never changes about who you are, no matter how much you achieve?',
      'What question will you ask yourself on your next birthday?',
      'If you could send a single sentence of encouragement to yourself three years from now, what would it be?',
    ];
    for (final p in futurePrompts) {
      addQ(p, 'My Future', ['future', 'goals', 'vision']);
    }

    // Additional deep reflection questions to build up to comprehensive catalog
    final categories = [
      'My Story',
      'My People',
      'My Interests',
      'My Future',
      'General',
    ];
    final themes = [
      'memory',
      'friendship',
      'gratitude',
      'craft',
      'hope',
      'silence',
      'family',
      'curiosity',
      'courage',
      'forgiveness',
      'nature',
      'routines',
      'books',
      'patience',
      'boundaries',
      'simplicity',
      'lessons',
      'travel',
      'home',
      'purpose',
    ];

    int catIdx = 0;
    int themeIdx = 0;
    while (questions.length < 520) {
      final category = categories[catIdx % categories.length];
      final theme = themes[themeIdx % themes.length];
      final num = questions.length + 1;

      String promptText;
      switch (theme) {
        case 'memory':
          promptText =
              'What is a quiet memory (#$num) that still brings you a sense of grounding?';
          break;
        case 'friendship':
          promptText =
              'What is an unspoken gesture of loyalty from a friend you never forgot (#$num)?';
          break;
        case 'gratitude':
          promptText =
              'What unexpected kindness did you witness or receive recently (#$num)?';
          break;
        case 'craft':
          promptText =
              'What is a technique or standard of craft you hold yourself to (#$num)?';
          break;
        case 'hope':
          promptText =
              'What future possibility gives you quiet optimism when things feel heavy (#$num)?';
          break;
        case 'silence':
          promptText =
              'Where do you go when you need your thoughts to settle down (#$num)?';
          break;
        case 'family':
          promptText =
              'What phrase or mannerism from your family do you catch yourself using (#$num)?';
          break;
        case 'curiosity':
          promptText =
              'What is something you learned this week that made you say "I did not know that" (#$num)?';
          break;
        case 'courage':
          promptText = 'When was a time you chose honesty over ease (#$num)?';
          break;
        case 'forgiveness':
          promptText =
              'What is a mistake you made that taught you greater compassion for others (#$num)?';
          break;
        case 'nature':
          promptText =
              'What season of the year feels most harmonious with your natural energy (#$num)?';
          break;
        case 'routines':
          promptText =
              'What small morning ritual keeps your day centered before demands arrive (#$num)?';
          break;
        case 'books':
          promptText =
              'What idea or passage from your reading has remained with you this month (#$num)?';
          break;
        case 'patience':
          promptText =
              'What is something in your life that cannot be rushed, only tended to (#$num)?';
          break;
        case 'boundaries':
          promptText =
              'What is a demand on your time that you have learned to decline without guilt (#$num)?';
          break;
        case 'simplicity':
          promptText =
              'What complication in your daily life would you love to strip away (#$num)?';
          break;
        case 'lessons':
          promptText =
              'What hard truth about yourself was difficult to accept but made you freer (#$num)?';
          break;
        case 'travel':
          promptText =
              'What street, road, or path do you look forward to walking again (#$num)?';
          break;
        case 'home':
          promptText =
              'What makes a room feel genuinely peaceful to you (#$num)?';
          break;
        default:
          promptText =
              'What is one thing you want to remember about this current chapter of your life (#$num)?';
      }

      addQ(promptText, category, [theme, 'reflection']);
      catIdx++;
      themeIdx++;
    }

    return questions;
  }
}
