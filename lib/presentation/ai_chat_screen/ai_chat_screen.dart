import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/chat_input_widget.dart';
import './widgets/chat_message_widget.dart';
import './widgets/quick_suggestions_widget.dart';
import './widgets/typing_indicator_widget.dart';
import './widgets/voice_message_widget.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen>
    with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;
  bool _showSuggestions = true;
  int _currentBottomIndex = 3; // AI Chat tab

  // Mock conversation data
  final List<Map<String, dynamic>> _mockConversation = [
    {
      'id': 1,
      'message':
          'Hello! I\'m your Zachuma AI financial advisor. I can help you with budgeting, investing, debt management, and more. What would you like to learn about today?',
      'type': MessageType.ai,
      'timestamp': DateTime.now().subtract(Duration(minutes: 5)),
      'isVoice': false,
    },
    {
      'id': 2,
      'message':
          'Hi! I\'m new to investing and want to understand the basics. Where should I start?',
      'type': MessageType.user,
      'timestamp': DateTime.now().subtract(Duration(minutes: 4)),
      'isVoice': false,
    },
    {
      'id': 3,
      'message':
          '''Great question! Here are the key investing basics for beginners: **1. Emergency Fund First** • Save 3-6 months of expenses before investing • Keep this in a high-yield savings account **2. Understand Risk vs Return** • Higher potential returns = higher risk • Diversification helps manage risk **3. Start with Index Funds** • Low fees (0.03-0.20% expense ratios) • Instant diversification • Good for beginners **4. Dollar-Cost Averaging** • Invest the same amount regularly • Reduces impact of market volatility **5. Tax-Advantaged Accounts** • 401(k) with employer match first • Then Roth IRA (\$6,500 limit for 2024) Would you like me to explain any of these concepts in more detail?''',
      'type': MessageType.ai,
      'timestamp': DateTime.now().subtract(Duration(minutes: 3)),
      'isVoice': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadInitialMessages();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // Handle keyboard appearance/disappearance
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollToBottom();
      }
    });
  }

  void _loadInitialMessages() {
    setState(() {
      _messages.addAll(_mockConversation);
      _showSuggestions = _messages.isEmpty;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Add user message
    final userMessage = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'message': message,
      'type': MessageType.user,
      'timestamp': DateTime.now(),
      'isVoice': false,
    };

    setState(() {
      _messages.add(userMessage);
      _showSuggestions = false;
      _isTyping = true;
    });

    _scrollToBottom();

    // Simulate AI response delay
    await Future.delayed(Duration(seconds: 2));

    // Generate AI response based on message content
    final aiResponse = _generateAIResponse(message);

    final aiMessage = {
      'id': DateTime.now().millisecondsSinceEpoch + 1,
      'message': aiResponse,
      'type': MessageType.ai,
      'timestamp': DateTime.now(),
      'isVoice': false,
    };

    setState(() {
      _messages.add(aiMessage);
      _isTyping = false;
    });

    _scrollToBottom();
  }

  String _generateAIResponse(String userMessage) {
    final message = userMessage.toLowerCase();

    if (message.contains('budget')) {
      return '''Here\'s a simple budgeting framework to get you started:

**50/30/20 Rule:**
• 50% - Needs (rent, utilities, groceries)
• 30% - Wants (entertainment, dining out)
• 20% - Savings & debt payments

**Steps to Create Your Budget:**
1. **Track your income** - List all money coming in
2. **List your expenses** - Fixed and variable costs
3. **Categorize spending** - Needs vs wants
4. **Set savings goals** - Emergency fund first
5. **Review monthly** - Adjust as needed

**Budgeting Apps to Consider:**
• Mint (free)
• YNAB (You Need A Budget)
• Personal Capital

Would you like help calculating your specific budget percentages?''';
    } else if (message.contains('invest') || message.contains('stock')) {
      return '''Investment fundamentals for beginners:

**Before You Invest:**
✅ Emergency fund (3-6 months expenses)
✅ High-interest debt paid off
✅ Stable income

**Investment Account Types:**
• **401(k)** - Employer match = free money!
• **Roth IRA** - Tax-free growth (\$6,500 limit)
• **Traditional IRA** - Tax deduction now
• **Taxable brokerage** - No limits, more flexibility

**Beginner-Friendly Investments:**
• **Target-date funds** - Auto-adjusts over time
• **S&P 500 index funds** - Tracks 500 largest US companies
• **Total market funds** - Entire US stock market

**Key Principles:**
• Start early (compound interest!)
• Diversify your holdings
• Keep fees low (<0.20%)
• Don\'t try to time the market

What\'s your investment timeline and risk tolerance?''';
    } else if (message.contains('debt')) {
      return '''Effective debt management strategies:

**Debt Payoff Methods:**

**1. Debt Avalanche** (Mathematically optimal)
• Pay minimums on all debts
• Extra money goes to highest interest rate
• Saves most money long-term

**2. Debt Snowball** (Psychologically motivating)
• Pay minimums on all debts
• Extra money goes to smallest balance
• Quick wins build momentum

**Priority Order:**
1. **Credit cards** (18-25% interest)
2. **Personal loans** (6-15% interest)
3. **Student loans** (3-7% interest)
4. **Mortgage** (3-6% interest)

**Debt Consolidation Options:**
• Balance transfer cards (0% intro APR)
• Personal loans (lower fixed rate)
• Home equity loans (tax deductible)

**Prevention Tips:**
• Build emergency fund
• Use credit cards responsibly
• Live below your means

What type of debt are you dealing with? I can provide more specific advice.''';
    } else if (message.contains('save') || message.contains('emergency')) {
      return '''Building your emergency fund:

**Emergency Fund Basics:**
• **Goal:** 3-6 months of living expenses
• **Purpose:** Unexpected expenses, job loss
• **Location:** High-yield savings account

**How Much to Save:**
• **Minimum:** \$1,000 starter fund
• **Conservative:** 6 months expenses
• **Aggressive:** 3 months expenses
• **Variable income:** 6-12 months expenses

**Where to Keep It:**
• **High-yield savings** (4-5% APY)
• **Money market accounts**
• **Short-term CDs**
• **NOT** in checking or investments

**Building Strategy:**
1. **Calculate monthly expenses** - Rent, food, utilities, etc.
2. **Set monthly savings goal** - Even \$50/month helps
3. **Automate transfers** - Pay yourself first
4. **Use windfalls** - Tax refunds, bonuses

**Current High-Yield Options:**
• Marcus by Goldman Sachs
• Ally Bank
• Capital One 360

How much are your monthly expenses? I can help calculate your target amount.''';
    } else if (message.contains('credit') || message.contains('score')) {
      return '''Understanding credit scores:

**Credit Score Ranges:**
• **800-850:** Excellent
• **740-799:** Very Good
• **670-739:** Good
• **580-669:** Fair
• **300-579:** Poor

**What Affects Your Score:**
• **Payment history (35%)** - Pay on time, always
• **Credit utilization (30%)** - Keep below 30%, ideally under 10%
• **Length of credit history (15%)** - Keep old accounts open
• **Credit mix (10%)** - Different types of credit
• **New credit (10%)** - Don\'t apply for too many cards

**Improving Your Score:**
1. **Pay all bills on time** - Set up autopay
2. **Pay down credit card balances** - Lower utilization
3. **Don\'t close old credit cards** - Maintains credit history
4. **Check credit reports** - Dispute errors (annualcreditreport.com)
5. **Be patient** - Improvements take 3-6 months

**Free Credit Monitoring:**
• Credit Karma
• Credit Sesame
• Your bank/credit card company

**Quick Wins:**
• Pay down cards before statement date
• Ask for credit limit increases
• Become authorized user on family member\'s card

What\'s your current credit score range? I can suggest specific improvement strategies.''';
    } else if (message.contains('retirement')) {
      return '''Retirement planning essentials:

**Retirement Savings Vehicles:**

**401(k) - Employer Plan**
• **2024 limit:** \$23,000 (\$30,500 if 50+)
• **Employer match:** Free money - always contribute enough to get full match
• **Tax benefit:** Reduces current taxable income

**Roth IRA - Individual Account**
• **2024 limit:** \$7,000 (\$8,000 if 50+)
• **Tax-free growth:** No taxes on withdrawals in retirement
• **Income limits:** Phases out at higher incomes

**Traditional IRA**
• **Same limits** as Roth IRA
• **Tax deduction** now, taxed in retirement
• **Required distributions** starting at 73

**How Much to Save:**
• **Rule of thumb:** 10-15% of income
• **Catch-up strategy:** Increase by 1% annually
• **Target:** 10-12x annual salary by retirement

**Investment Strategy by Age:**
• **20s-30s:** 80-90% stocks, 10-20% bonds
• **40s-50s:** 70-80% stocks, 20-30% bonds
• **60s+:** 50-60% stocks, 40-50% bonds

**Retirement Timeline:**
• **Age 59½:** Can withdraw from retirement accounts without penalty
• **Age 62:** Earliest Social Security (reduced benefits)
• **Age 67:** Full Social Security benefits
• **Age 73:** Required minimum distributions from traditional accounts

What\'s your current age and retirement savings situation?''';
    } else if (message.contains('hello') || message.contains('hi')) {
      return '''Hello! Welcome back to your AI financial advisor. I\'m here to help you with:

💰 **Budgeting & Saving**
📈 **Investing & Retirement Planning**  
💳 **Credit & Debt Management**
🏠 **Major Purchase Planning**
📊 **Financial Goal Setting**

I can provide personalized advice, explain complex concepts in simple terms, and help you create actionable financial plans.

What financial topic would you like to explore today?''';
    } else {
      return '''I understand you\'re asking about "${userMessage}". Let me provide some helpful information:

This is a great financial question! While I can provide general guidance, here are some key points to consider:

• **Research thoroughly** before making any financial decisions
• **Consider your personal situation** - income, expenses, goals, and risk tolerance
• **Consult professionals** for complex situations - financial advisors, tax professionals, etc.
• **Start small** and build your knowledge over time

**Recommended Resources:**
• Books: "The Simple Path to Wealth" by JL Collins
• Websites: Bogleheads.org, Investopedia
• Podcasts: "The Investors Podcast", "Chat with Traders"

Would you like me to elaborate on any specific aspect of your question? I can provide more detailed guidance on budgeting, investing, debt management, or retirement planning.''';
    }
  }

  void _handleVoiceMessage(String audioPath) {
    final voiceMessage = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'message': 'Voice message',
      'type': MessageType.user,
      'timestamp': DateTime.now(),
      'isVoice': true,
      'audioPath': audioPath,
      'duration': Duration(seconds: 15), // Mock duration
    };

    setState(() {
      _messages.add(voiceMessage);
      _showSuggestions = false;
    });

    _scrollToBottom();

    // Simulate voice processing and response
    Future.delayed(Duration(seconds: 3), () {
      _sendMessage('I received your voice message about budgeting tips.');
    });
  }

  void _handleSuggestionTap(String suggestion) {
    _sendMessage(suggestion);
  }

  void _handleThumbsUp(int messageId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Thanks for the positive feedback!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleThumbsDown(int messageId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Thanks for the feedback. I\'ll try to improve!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear Chat'),
        content: Text(
            'Are you sure you want to clear all messages? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _messages.clear();
                _showSuggestions = true;
              });
            },
            child: Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _onBottomNavTap(int index) {
    if (index == _currentBottomIndex) return;

    setState(() {
      _currentBottomIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/dashboard-screen');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/course-catalog-screen');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/assessment-quiz-screen');
        break;
      case 3:
        // Current screen - AI Chat
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profile-screen');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'AI Financial Advisor',
        variant: CustomAppBarVariant.withActions,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 2.w),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 2.w,
                  height: 2.w,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 1.w),
                Text(
                  'Online',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 3.w),
                GestureDetector(
                  onTap: _clearChat,
                  child: CustomIconWidget(
                    iconName: 'settings',
                    color: theme.colorScheme.onSurface,
                    size: 6.w,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty && _showSuggestions
                ? _buildEmptyState()
                : _buildChatArea(),
          ),
          if (_showSuggestions && _messages.isNotEmpty)
            QuickSuggestionsWidget(
              onSuggestionTap: _handleSuggestionTap,
              isVisible: _showSuggestions,
            ),
          TypingIndicatorWidget(isVisible: _isTyping),
          ChatInputWidget(
            onSendMessage: _sendMessage,
            onVoiceMessage: _handleVoiceMessage,
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(6.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 10.h),
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: CustomIconWidget(
              iconName: 'smart_toy',
              color: theme.colorScheme.primary,
              size: 10.w,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'AI Financial Advisor',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'I\'m here to help you with budgeting, investing, debt management, and all your financial questions. Ask me anything!',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6.h),
          QuickSuggestionsWidget(
            onSuggestionTap: _handleSuggestionTap,
            isVisible: true,
          ),
        ],
      ),
    );
  }

  Widget _buildChatArea() {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.only(top: 2.h, bottom: 2.h),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isVoice = message['isVoice'] ?? false;

        if (isVoice) {
          return VoiceMessageWidget(
            audioPath: message['audioPath'] ?? '',
            isUser: message['type'] == MessageType.user,
            duration: message['duration'] ?? Duration(seconds: 0),
            onPlay: () {
              // Handle voice message play
            },
            onPause: () {
              // Handle voice message pause
            },
          );
        }

        return ChatMessageWidget(
          message: message['message'],
          type: message['type'],
          timestamp: message['timestamp'],
          showTimestamp: index == _messages.length - 1 ||
              (index < _messages.length - 1 &&
                  _messages[index + 1]['type'] != message['type']),
          onThumbsUp: message['type'] == MessageType.ai
              ? () => _handleThumbsUp(message['id'])
              : null,
          onThumbsDown: message['type'] == MessageType.ai
              ? () => _handleThumbsDown(message['id'])
              : null,
          onCopy: () {
            // Handle copy message
          },
          onShare: () {
            // Handle share message
          },
        );
      },
    );
  }
}
