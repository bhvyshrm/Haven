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
    if (templates.isEmpty ||
        !templates.any((t) => t.category == 'Feelings & Reflection')) {
      await db.insertTemplates(_generateTemplates());
    }
  }

  static List<HavenTemplate> _generateTemplates() {
    return [
      // =======================================================================
      // 1. ABOUT ME
      // =======================================================================
      const HavenTemplate(
        id: 'tpl_about_person_today',
        title: 'The Person I Am Today',
        category: 'About Me',
        description:
            'Core truths, working habits, and what feels true right now.',
        version: 2,
        content: '''# The Person I Am Today

### Where I Am Right Now
- What is occupying my mind these days: 
- What is giving me energy: 
- What has been draining my energy: 

### Core Truths
- A boundary I am learning to protect: 
- What matters to me more than it used to: 
- What matters to me less than it used to: 

### My Quiet Daily Rhythm
- Morning habits that ground me: 
- When I feel most like myself: 
- How I decompress when the day is done: ''',
      ),
      const HavenTemplate(
        id: 'tpl_about_feel_like_myself',
        title: 'Things That Make Me Feel Like Myself',
        category: 'About Me',
        description: 'The music, clothes, places, and small moments that bring you home to who you are.',
        version: 2,
        content: '''# Things That Make Me Feel Like Myself

### Familiar Anchors
- An outfit or item of clothing I feel completely comfortable in: 
- Music or sounds that instantly reset my mood: 
- A place where I can drop my shoulders: 

### What I Do When Unwatched
- How I spend an unstructured hour alone: 
- Things I care about that I don't talk to many people about: 
- A simple habit that makes me feel grounded: ''',
      ),
      const HavenTemplate(
        id: 'tpl_about_comfort_things',
        title: 'My Comfort Things',
        category: 'About Me',
        description: 'Safe spaces, warm drinks, routines, and quiet comforts.',
        version: 2,
        content: '''# My Comfort Things

### Everyday Comforts
- My go-to warm drink or food: 
- A sensory detail that brings calm (light, texture, scent): 
- A book, film, or album I revisit for reassurance: 

### Safe Spaces
- A corner of my room or home that feels safe: 
- Someone whose presence demands nothing from me: 
- What quiet looks and feels like for me: ''',
      ),
      const HavenTemplate(
        id: 'tpl_about_hidden_sides',
        title: 'A Few Things People May Not Know About Me',
        category: 'About Me',
        description:
            'Quiet sides, unspoken curiosities, and things felt deeply.',
        version: 2,
        content: '''# A Few Things People May Not Know About Me

### Beneath the Surface
- Something I feel deeply about that I rarely mention: 
- A quiet curiosity or hobby I enjoy in private: 
- Something that requires courage for me that looks easy to others: 

### Looking Inward
- How I talk to myself when no one is listening: 
- A truth I am gradually accepting about myself: ''',
      ),
      const HavenTemplate(
        id: 'tpl_about_what_matters',
        title: 'What Matters to Me',
        category: 'About Me',
        description:
            'Defining your values, what you protect, and your sense of enough.',
        version: 2,
        content: '''# What Matters to Me

### Core Priorities
- The values I refuse to compromise on: 
- What kind of person I want to be to those around me: 

### Enough
- When I will know I have done enough today: 
- Pressures I am choosing not to take on: ''',
      ),

      // =======================================================================
      // 2. FAMILY
      // =======================================================================
      const HavenTemplate(
        id: 'tpl_family_little_things',
        title: 'Little Things About My Family',
        category: 'Family',
        description:
            'Small quirks, phrases only you understand, and shared history.',
        version: 2,
        content: '''# Little Things About My Family

### The Quirks
- A phrase or inside joke only my family understands: 
- A funny habit someone in my family has: 
- An unwritten rule in our home: 

### Shared History
- A story that always gets retold when we are together: 
- Something about my family that helped shape who I am: ''',
      ),
      const HavenTemplate(
        id: 'tpl_family_memories_home',
        title: 'Memories of Home',
        category: 'Family',
        description:
            'Scents of dinner, sounds of the house, and how the rooms felt.',
        version: 2,
        content: '''# Memories of Home

### The Atmosphere
- Sounds I associate with home (doors closing, footsteps, radio): 
- The smell of the kitchen at dinner time: 
- Where the light fell in the afternoons: 

### Small Moments
- A quiet moment at home that stayed in my memory: 
- What home means to me today: ''',
      ),
      const HavenTemplate(
        id: 'tpl_family_parents_lessons',
        title: 'Things My Parents Taught Me',
        category: 'Family',
        description: 'Lessons learned, things to carry forward, and things chosen differently.',
        version: 2,
        content: '''# Things My Parents Taught Me

### Things They Showed Me
- A value or work ethic they lived by: 
- A kind gesture or sacrifice I noticed over time: 

### What I Choose
- Something I want to carry forward into my own life: 
- Something I consciously choose to do differently: ''',
      ),
      const HavenTemplate(
        id: 'tpl_family_meal_home',
        title: 'A Meal That Feels Like Home',
        category: 'Family',
        description:
            'The food, who cooked it, and the warmth around the table.',
        version: 2,
        content: '''# A Meal That Feels Like Home

### The Dish
- What the dish is and who usually prepared it: 
- The smells in the kitchen while it was being made: 

### The Feeling
- How it feels to eat it after being away: 
- A conversation or silence that accompanied that meal: ''',
      ),
      const HavenTemplate(
        id: 'tpl_family_what_home_means',
        title: 'What Home Means to Me',
        category: 'Family',
        description: 'Feeling safe, places where you can exhale, and what makes a refuge.',
        version: 2,
        content: '''# What Home Means to Me

### The Refuge
- Is home a place, a person, or a state of mind for me: 
- Where I feel completely safe to let my guard down: 
- What I hope my own future home will feel like to anyone walking in: ''',
      ),

      // =======================================================================
      // 3. MY PEOPLE
      // =======================================================================
      const HavenTemplate(
        id: 'tpl_people_shaped_life',
        title: 'People Who Have Shaped My Life',
        category: 'My People',
        description:
            'Mentors, friends, and quiet anchors who altered your journey.',
        version: 2,
        content: '''# People Who Have Shaped My Life

### The Person
- Name or who they are: 
- How our paths crossed: 

### The Impact
- How they changed my perspective or helped me grow: 
- A specific conversation or moment I cherish: 
- A quality of theirs I hope to embody: ''',
      ),
      const HavenTemplate(
        id: 'tpl_people_admire_friends',
        title: 'Things I Admire About My Friends',
        category: 'My People',
        description:
            'Their quiet courage, humor, loyalty, and how they show up.',
        version: 2,
        content: '''# Things I Admire About My Friends

### What I Notice
- A friend whose kindness consistently surprises me: 
- Someone whose honesty or humor makes heavy days lighter: 
- How they show up when things are difficult: 

### Gratitude
- What makes our friendship feel easy and safe: 
- A recent moment where I felt grateful for them: ''',
      ),
      const HavenTemplate(
        id: 'tpl_people_feeling_safe',
        title: 'What Makes Me Feel Safe Around Someone',
        category: 'My People',
        description: 'The absence of judgment, comfortable silence, and genuine acceptance.',
        version: 2,
        content: '''# What Makes Me Feel Safe Around Someone

### The Environment
- Being able to be silent without it feeling awkward: 
- Knowing I don't have to perform or prove anything: 
- How they respond when I share a mistake or worry: 

### The Anchors
- Who comes to mind when I think of emotional safety: 
- How my body feels when I am around people I trust: ''',
      ),
      const HavenTemplate(
        id: 'tpl_people_make_me_laugh',
        title: 'People Who Make Me Laugh',
        category: 'My People',
        description:
            'The people who bring effortless lightness and genuine smiles.',
        version: 2,
        content: '''# People Who Make Me Laugh

### The Lightness
- Who makes me laugh until my stomach aches: 
- A funny memory or situation we found ourselves in: 
- Why their presence makes life feel more bearable: ''',
      ),

      // =======================================================================
      // 4. CHILDHOOD & MEMORIES
      // =======================================================================
      const HavenTemplate(
        id: 'tpl_childhood_memory',
        title: 'A Childhood Memory I Still Remember',
        category: 'Childhood & Memories',
        description:
            'Sensory details, light, weather, and a moment that never left.',
        version: 2,
        content: '''# A Childhood Memory I Still Remember

### The Scene
- Approximately how old I was: 
- Where I was and what the season felt like: 
- What was happening around me: 

### Sensory Details
- What I could see, hear, or smell: 
- How big the world felt in that moment: 

### Looking Back
- Why this specific memory stayed with me: ''',
      ),
      const HavenTemplate(
        id: 'tpl_childhood_place',
        title: 'My Favourite Place Growing Up',
        category: 'Childhood & Memories',
        description:
            'A tree, a room corner, a porch, or an afternoon hideaway.',
        version: 2,
        content: '''# My Favourite Place Growing Up

### The Place
- Where it was and what it looked like: 
- Why I loved going there: 

### What I Did There
- Daydreams, games, or quiet reading: 
- How safe or free I felt in that space: ''',
      ),
      const HavenTemplate(
        id: 'tpl_childhood_ordinary_day',
        title: 'An Ordinary Day I Miss',
        category: 'Childhood & Memories',
        description:
            'The simplicity of an uncomplicated morning from the past.',
        version: 2,
        content: '''# An Ordinary Day I Miss

### The Morning
- Waking up without deadlines or heavy responsibilities: 
- What morning cartoons, breakfast, or sunlight felt like: 

### The Hours
- How time stretched out slowly: 
- What I would give to revisit that simplicity for an hour: ''',
      ),

      // =======================================================================
      // 5. COLLEGE & SCHOOL
      // =======================================================================
      const HavenTemplate(
        id: 'tpl_school_life_so_far',
        title: 'My Student Life So Far',
        category: 'College & School',
        description:
            'Finding rhythm, campus walks, and navigating independence.',
        version: 2,
        content: '''# My Student Life So Far

### Current Reality
- The classes or subjects occupying my time: 
- Where I usually sit or study: 
- What has felt overwhelming recently: 

### Small Wins
- A routine or habit I am figuring out: 
- Something I handled better than I thought I would: ''',
      ),
      const HavenTemplate(
        id: 'tpl_school_outside_class',
        title: 'Things I Have Learned Outside Class',
        category: 'College & School',
        description:
            'Budgeting energy, managing solitude, and real-world wisdom.',
        version: 2,
        content: '''# Things I Have Learned Outside Class

### Life Lessons
- What living on my own or growing up has taught me: 
- How I deal with feeling lonely or out of place: 
- What I have learned about choosing friends who respect my pace: 

### Personal Growth
- Releasing the pressure to have everything figured out: ''',
      ),
      const HavenTemplate(
        id: 'tpl_school_small_wins',
        title: 'Small Wins This Week',
        category: 'College & School',
        description:
            'Showing up, cooking a meal, getting through a tough exam.',
        version: 2,
        content: '''# Small Wins This Week

### What I Did
- One thing I showed up for even when I felt tired: 
- A small task I finished that I was putting off: 
- A healthy boundary or rest break I gave myself: 

### Perspective
- Reminding myself that small steady steps are enough: ''',
      ),

      // =======================================================================
      // 6. FEELINGS & REFLECTION (Gentle, depression-sensitive, low-pressure)
      // =======================================================================
      const HavenTemplate(
        id: 'tpl_feelings_how_am_i',
        title: 'How Am I Really Feeling Today?',
        category: 'Feelings & Reflection',
        description:
            'No fixing, no pretending. Putting honest words to what is here.',
        version: 2,
        content: '''# How Am I Really Feeling Today?

### Naming It Gently
- If I stop pretending to have it all together, I feel: 
- Where in my body I am holding tension or heaviness: 
- What has been sitting on my chest lately: 

### No Need to Fix
- It is okay to not be okay right now.
- What I need to acknowledge without judging myself: ''',
      ),
      const HavenTemplate(
        id: 'tpl_feelings_make_today_easier',
        title: 'What Would Make Today a Little Easier?',
        category: 'Feelings & Reflection',
        description:
            'Lowering expectations. Choosing what can soften the hours.',
        version: 2,
        content: '''# What Would Make Today a Little Easier?

### Less Pressure
- One expectation I can take off my shoulders right now: 
- Something I can do half-way or leave unfinished: 

### Small Comfort
- A glass of water, ten minutes of quiet, or washing my face: 
- Something soft or warm I can give myself today: ''',
      ),
      const HavenTemplate(
        id: 'tpl_feelings_wait_tomorrow',
        title: 'What Can Wait Until Tomorrow?',
        category: 'Feelings & Reflection',
        description: 'Giving yourself permission to put down the heavy things.',
        version: 2,
        content: '''# What Can Wait Until Tomorrow?

### Putting It Down
- A task that is creating anxiety that does not actually need to happen today: 
- A decision I do not need to make tonight: 
- An email or message that can wait until I have energy: 

### Exhaling
- The world will not break if I rest right now.
- What resting would look like for the next hour: ''',
      ),
      const HavenTemplate(
        id: 'tpl_feelings_draining_energy',
        title: 'What Has Been Draining My Energy?',
        category: 'Feelings & Reflection',
        description:
            'Quietly identifying invisible drains without guilt or blame.',
        version: 2,
        content: '''# What Has Been Draining My Energy?

### The Invisible Weights
- Interactions or environments that have felt exhausting: 
- Internal pressures or self-criticism I have been repeating: 
- Things outside my control that I have been carrying: 

### Stepping Back
- Where can I pull back my attention and protect my peace: ''',
      ),
      const HavenTemplate(
        id: 'tpl_feelings_need_to_hear',
        title: 'What Do I Need to Hear Right Now?',
        category: 'Feelings & Reflection',
        description:
            'The words of kindness you would give to an exhausted friend.',
        version: 2,
        content: '''# What Do I Need to Hear Right Now?

### Kindness to Myself
- If my dearest friend were carrying this, I would tell them: 
- You have survived hard days before, and you do not have to conquer today all at once.
- Taking things one hour at a time is enough.
- You are allowed to be tired without feeling guilty about it.''',
      ),
      const HavenTemplate(
        id: 'tpl_feelings_grounded',
        title: 'What Helps Me Feel Grounded?',
        category: 'Feelings & Reflection',
        description:
            'Sensory anchors, breathing room, and simple physical reality.',
        version: 2,
        content: '''# What Helps Me Feel Grounded?

### Physical Anchors
- Feeling my feet flat on the floor: 
- Stepping outside to feel the cool air on my skin: 
- Taking three slow breaths and letting my shoulders drop: 
- Remembering that this feeling is a season, not a permanent place.''',
      ),
      const HavenTemplate(
        id: 'tpl_feelings_outside_control',
        title: 'What Is Outside My Control Right Now?',
        category: 'Feelings & Reflection',
        description:
            'Recognizing what is not yours to fix, and letting go of the grip.',
        version: 2,
        content: '''# What Is Outside My Control Right Now?

### Not Mine to Carry
- Things I cannot force or change tonight: 
- Other people's moods, choices, or expectations: 

### What I Can Control
- How gently I treat myself in this hour: 
- Drinking water, getting rest, and turning off the noise: ''',
      ),

      // =======================================================================
      // 7. EVERYDAY LIFE
      // =======================================================================
      const HavenTemplate(
        id: 'tpl_everyday_five_things',
        title: 'Five Small Things I Enjoy',
        category: 'Everyday Life',
        description:
            'Morning coffee steam, clean sheets, rain, and simple details.',
        version: 2,
        content: '''# Five Small Things I Enjoy

1. 
2. 
3. 
4. 
5. 

### A Note on Simplicity
- Why these small moments keep me grounded: ''',
      ),
      const HavenTemplate(
        id: 'tpl_everyday_slow_morning',
        title: 'My Perfect Slow Morning',
        category: 'Everyday Life',
        description:
            'No alarms, soft light, time moving at your unhurried pace.',
        version: 2,
        content: '''# My Perfect Slow Morning

### Waking Up
- What the room looks and feels like: 
- How I make my morning tea or coffee: 
- The absence of rush or urgency: 

### The First Hours
- What I choose to read, listen to, or look at: ''',
      ),
      const HavenTemplate(
        id: 'tpl_everyday_make_day_better',
        title: 'Things That Make an Ordinary Day Better',
        category: 'Everyday Life',
        description:
            'Comfort in the mundane: quiet walks, good bread, evening air.',
        version: 2,
        content: '''# Things That Make an Ordinary Day Better

### The Little Details
- A song played with headphones while walking: 
- A warm shower after being outside in the cold: 
- The feeling of crossing something off a list or turning off the screen: ''',
      ),
      const HavenTemplate(
        id: 'tpl_everyday_peaceful_day',
        title: 'What a Peaceful Day Looks Like',
        category: 'Everyday Life',
        description: 'The absence of rushing, quiet spaces, simple food, permission to just be.',
        version: 2,
        content: '''# What a Peaceful Day Looks Like

### The Atmosphere
- No notifications, no urgent demands: 
- A walk with no destination: 
- Sitting with a warm cup and watching the light shift: ''',
      ),

      // =======================================================================
      // 8. THINGS I LOVE
      // =======================================================================
      const HavenTemplate(
        id: 'tpl_things_songs',
        title: 'Songs I Keep Coming Back To',
        category: 'Things I Love',
        description:
            'Melodies that feel like home and lyrics that speak for you.',
        version: 2,
        content: '''# Songs I Keep Coming Back To

### The Playlist
- A song that calms my nervous system: 
- A song that holds memories of a specific time: 
- A song that makes me feel hopeful or understood: 

### The Resonance
- Lines or melodies that never get old: ''',
      ),
      const HavenTemplate(
        id: 'tpl_things_movies_books',
        title: 'Comfort Movies and Books',
        category: 'Things I Love',
        description: 'Fictional worlds where you feel welcome, calm, and safe.',
        version: 2,
        content: '''# Comfort Movies and Books

### What I Rewatch / Reread
- The film I put on when I am feeling sick or overwhelmed: 
- A book whose pages feel like a familiar room: 
- Characters who feel like friends: ''',
      ),
      const HavenTemplate(
        id: 'tpl_things_weather',
        title: 'My Favourite Weather',
        category: 'Things I Love',
        description:
            'Autumn chill, rain against the window, grey skies, and clean air.',
        version: 2,
        content: '''# My Favourite Weather

### The Sky
- The kind of weather that makes me feel most peaceful: 
- The sounds of rain, wind, or absolute winter silence: 
- How the world slows down when the weather turns grey: ''',
      ),
      const HavenTemplate(
        id: 'tpl_things_my_room',
        title: 'Things I Love About My Room',
        category: 'Things I Love',
        description:
            'The corner where the lamp glows, pillows, your quiet sanctuary.',
        version: 2,
        content: '''# Things I Love About My Room

### The Sanctuary
- The corner of the room where I feel most at ease: 
- Objects on my desk or shelf that carry quiet memories: 
- How it feels to close the door at night: ''',
      ),

      // =======================================================================
      // 9. DREAMS & FUTURE
      // =======================================================================
      const HavenTemplate(
        id: 'tpl_dreams_life_build',
        title: 'A Life I Would Like to Build',
        category: 'Dreams & Future',
        description: 'A quiet kitchen, meaningful work, unhurried weekends.',
        version: 2,
        content: '''# A Life I Would Like to Build

### The Feeling of Daily Life
- How I want my mornings and evenings to feel: 
- The kind of work that would feel honest and rewarding: 
- The people I want around my table: 

### Defining Enough
- What "enough" looks like without needing excess: ''',
      ),
      const HavenTemplate(
        id: 'tpl_dreams_stop_rushing',
        title: 'Things I Want to Stop Rushing',
        category: 'Dreams & Future',
        description:
            'Allowing yourself room to grow without comparing timelines.',
        version: 2,
        content: '''# Things I Want to Stop Rushing

### Giving Myself Time
- Stop rushing through my healing or recovery: 
- Stop comparing my timeline with people on social media: 
- Remembering that slow growth produces deep roots: ''',
      ),
      const HavenTemplate(
        id: 'tpl_dreams_what_success_means',
        title: 'What Success Means to Me',
        category: 'Dreams & Future',
        description:
            'Peace of mind, honest sleep, and living without chronic dread.',
        version: 2,
        content: '''# What Success Means to Me

### Beyond Status
- Living without constant anxiety: 
- Having time for the people I care about: 
- Liking who I am when I look in the mirror at night: ''',
      ),

      // =======================================================================
      // 10. GRATITUDE & SMALL JOYS (Low pressure, gentle)
      // =======================================================================
      const HavenTemplate(
        id: 'tpl_gratitude_one_thing',
        title: 'One Thing I Appreciated Today',
        category: 'Gratitude & Small Joys',
        description:
            'Just one thing. A soft bed, clean water, or a quiet moment.',
        version: 2,
        content: '''# One Thing I Appreciated Today

### One Simple Thing
- What happened or what existed that I am glad for: 
- Why it made a difference, however small: ''',
      ),
      const HavenTemplate(
        id: 'tpl_gratitude_small_comfort',
        title: 'A Small Comfort I Had Today',
        category: 'Gratitude & Small Joys',
        description: 'A moment where life felt a little softer.',
        version: 2,
        content: '''# A Small Comfort I Had Today

### The Moment
- What was happening: 
- How it helped me take a breath and relax: ''',
      ),
      const HavenTemplate(
        id: 'tpl_gratitude_glad_exists',
        title: 'Something I Am Glad Exists',
        category: 'Gratitude & Small Joys',
        description:
            'Tea, dogs on walks, old libraries, quiet evenings, starry skies.',
        version: 2,
        content: '''# Something I Am Glad Exists

- Something in this world that brings pure simplicity: 
- Why it brings a small smile: ''',
      ),

      // =======================================================================
      // 11. LIFE LESSONS
      // =======================================================================
      const HavenTemplate(
        id: 'tpl_lessons_learned_this_year',
        title: 'What I Have Learned This Year',
        category: 'Life Lessons',
        description: 'Quiet wisdom, boundaries, and what actually matters.',
        version: 2,
        content: '''# What I Have Learned This Year

### Wisdom Earned
- Something I used to worry about that matters less now: 
- A boundary I learned to draw without apologizing: 
- What I learned about asking for help when I need it: ''',
      ),
      const HavenTemplate(
        id: 'tpl_lessons_younger_self',
        title: 'What I Would Tell My Younger Self',
        category: 'Life Lessons',
        description:
            'Gentle reassurance for the version of you who was afraid.',
        version: 2,
        content: '''# What I Would Tell My Younger Self

### Reassurance
- You didn't have to carry the weight of the whole world: 
- You are going to survive the things that feel impossible right now: 
- It is okay to be sensitive; your gentleness is a strength: ''',
      ),
      const HavenTemplate(
        id: 'tpl_lessons_when_busy',
        title: 'Things I Want to Remember When Life Gets Busy',
        category: 'Life Lessons',
        description:
            'Slow down; breathe; nobody is keeping score of your productivity.',
        version: 2,
        content: '''# Things I Want to Remember When Life Gets Busy

### Slowing Down
- My worth is not defined by how much I produce today: 
- Taking a break is not a luxury, it is maintenance: 
- It is okay to say no to protect my mental health: ''',
      ),

      // =======================================================================
      // 12. LETTERS I NEVER SENT
      // =======================================================================
      const HavenTemplate(
        id: 'tpl_letters_someone_miss',
        title: 'A Letter to Someone I Miss',
        category: 'Letters I Never Sent',
        description: 'Speaking into the quiet without any pressure of sending.',
        version: 2,
        content: '''# A Letter to Someone I Miss

Dear ...,

I was thinking about you today. 

### What I Remember
- A memory of us that came back to me: 
- What I wish I could tell you: 

### What I Wish For You
- I hope you are doing well and finding peace.''',
      ),
      const HavenTemplate(
        id: 'tpl_letters_person_becoming',
        title: 'A Letter to the Person I Am Becoming',
        category: 'Letters I Never Sent',
        description: 'A promise of patience, kindness, and space to stumble.',
        version: 2,
        content: '''# A Letter to the Person I Am Becoming

Dear future me,

I am writing this from where I am right now. 

### A Promise to Myself
- I promise to be patient with you while you grow: 
- I promise not to judge you for taking breaks: 
- What I hope you never forget about where we came from: ''',
      ),
      const HavenTemplate(
        id: 'tpl_letters_never_got_to_say',
        title: 'Things I Never Got to Say',
        category: 'Letters I Never Sent',
        description:
            'Unspoken gratitude, gentle closure, words left in the quiet.',
        version: 2,
        content: '''# Things I Never Got to Say

### Speaking in Private
- Something I kept to myself: 
- What I feel when I think about it now: 
- Letting the words exist here, safe and private.''',
      ),
      const HavenTemplate(
        id: 'tpl_letters_younger_self',
        title: 'A Letter to My Younger Self',
        category: 'Letters I Never Sent',
        description:
            'Writing back to the younger you with love and understanding.',
        version: 2,
        content: '''# A Letter to My Younger Self

Dear younger me,

I see how hard you were trying.

### What I Want You to Know
- You are not broken, and you are not alone: 
- The things you worried about so deeply worked out: 
- Thank you for holding on until we got here.''',
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
