# AI Providers Guide

The Mathematics Homework Solver now supports multiple AI providers through a flexible provider pattern architecture. You can easily switch between OpenAI, Google Gemini, or use a mock provider for development.

## 🎯 Quick Start

### Using Gemini (Recommended for cost-effectiveness)

1. **Get a Gemini API Key:**
   - Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
   - Create a new API key

2. **Set Environment Variable:**
   ```bash
   export GEMINI_API_KEY=your_gemini_api_key_here
   export AI_PROVIDER=gemini
   ```

3. **Or add to your `.env` file:**
   ```env
   AI_PROVIDER=gemini
   GEMINI_API_KEY=your_gemini_api_key_here
   AI_MODEL=gemini-pro
   ```

### Using OpenAI

1. **Get an OpenAI API Key:**
   - Visit [OpenAI Platform](https://platform.openai.com/api-keys)
   - Create a new API key

2. **Configure:**
   ```bash
   export OPENAI_API_KEY=your_openai_api_key_here
   export AI_PROVIDER=openai
   ```

### Auto-Detection

If you don't specify a provider, the system will automatically detect which provider to use based on available API keys:

1. First checks for Gemini API key
2. Then checks for OpenAI API key  
3. Falls back to mock provider if none found

## 🏗️ Architecture

### Provider Pattern Structure

```
services/ai_providers/
├── base_provider.py           # Abstract base class
├── openai_provider.py         # OpenAI GPT implementation
├── gemini_provider.py         # Google Gemini implementation
├── mock_provider.py           # Mock provider for testing
└── provider_factory.py       # Factory for creating providers
```

### Key Components

#### 1. Base Provider (`AIProvider`)
Abstract base class that defines the interface all providers must implement:

```python
class AIProvider(ABC):
    @abstractmethod
    async def solve_single_question(self, question: Question) -> Question:
        """Solve a single mathematical question"""
        pass
    
    @abstractmethod
    async def generate_overall_explanation(self, solved_questions: List[Question]) -> str:
        """Generate an overall explanation"""
        pass
```

#### 2. Provider Factory (`AIProviderFactory`)
Creates and manages provider instances:

```python
# Auto-detect provider
provider = AIProviderFactory.get_provider()

# Specify provider
provider = AIProviderFactory.get_provider(
    provider_name="gemini",
    model="gemini-pro",
    api_key="your_key"
)
```

#### 3. Math Solver Service
Updated to use providers:

```python
solver = MathSolverService(
    provider_name="gemini",
    model="gemini-pro"
)
```

## 🔧 Configuration Options

### Environment Variables

| Variable | Description | Example Values |
|----------|-------------|----------------|
| `AI_PROVIDER` | Which provider to use | `openai`, `gemini`, `mock`, `auto` |
| `AI_MODEL` | Specific model to use | `gpt-4`, `gemini-pro`, `gemini-1.5-pro` |
| `OPENAI_API_KEY` | OpenAI API key | `sk-...` |
| `GEMINI_API_KEY` | Gemini API key | `AIza...` |
| `GOOGLE_API_KEY` | Alternative Gemini key | `AIza...` |

### Supported Models

#### OpenAI Models
- `gpt-4` (default)
- `gpt-4-turbo`
- `gpt-4-turbo-preview`
- `gpt-3.5-turbo`
- `gpt-3.5-turbo-16k`

#### Gemini Models
- `gemini-pro` (default)
- `gemini-pro-vision`
- `gemini-1.5-pro`
- `gemini-1.5-flash`

## 🧪 Testing

### Test All Providers

```bash
cd src/backend
python test_providers.py
```

This script will:
- Check environment configuration
- List available providers
- Test each provider with sample questions
- Show usage instructions

### Test Specific Provider

```python
from services.ai_providers.provider_factory import AIProviderFactory

# Test Gemini
provider = AIProviderFactory.get_provider("gemini")
print(f"Provider: {provider.provider_name}")
print(f"Available: {provider.is_available}")
```

## 🌐 API Endpoints

### Get Provider Information

```http
GET /ai-providers
```

Response:
```json
{
  "available_providers": {
    "openai": {
      "name": "OpenAI",
      "available": true,
      "models": ["gpt-4", "gpt-3.5-turbo"],
      "has_api_key": true
    },
    "gemini": {
      "name": "Google Gemini", 
      "available": true,
      "models": ["gemini-pro", "gemini-1.5-pro"],
      "has_api_key": true
    }
  },
  "current_provider": {
    "provider_name": "Google Gemini",
    "is_available": true,
    "supported_models": ["gemini-pro", "gemini-1.5-pro"]
  }
}
```

### Get Current Provider

```http
GET /ai-providers/current
```

Response:
```json
{
  "provider_name": "Google Gemini",
  "is_available": true,
  "supported_models": ["gemini-pro", "gemini-1.5-pro"]
}
```

## 💰 Cost Comparison

### Google Gemini (Recommended)
- **Cost**: $0.00025 per 1K characters (input), $0.0005 per 1K characters (output)
- **Free Tier**: 60 requests per minute
- **Best For**: High volume, cost-sensitive applications

### OpenAI GPT-4
- **Cost**: $0.03 per 1K tokens (input), $0.06 per 1K tokens (output)  
- **Best For**: Highest quality responses, complex reasoning

### Cost Example
For solving 100 homework problems (avg 200 tokens each):
- **Gemini**: ~$0.02
- **OpenAI GPT-4**: ~$2.40

*Gemini is ~120x cheaper!*

## 🔄 Switching Providers at Runtime

### Method 1: Environment Variables
```bash
# Switch to Gemini
export AI_PROVIDER=gemini
# Restart the server

# Switch to OpenAI  
export AI_PROVIDER=openai
# Restart the server
```

### Method 2: Configuration File
Update your `.env` file:
```env
AI_PROVIDER=gemini
AI_MODEL=gemini-1.5-pro
```

### Method 3: Programmatic (for custom integrations)
```python
from services.math_solver_service import MathSolverService

# Create solver with specific provider
solver = MathSolverService(
    provider_name="gemini",
    model="gemini-pro"
)
```

## 🛠️ Adding New Providers

### 1. Create Provider Class

```python
# services/ai_providers/my_provider.py
from .base_provider import AIProvider

class MyCustomProvider(AIProvider):
    def _check_availability(self) -> bool:
        return self.api_key is not None
    
    @property 
    def provider_name(self) -> str:
        return "My Custom Provider"
    
    @property
    def supported_models(self) -> List[str]:
        return ["model-1", "model-2"]
    
    async def solve_single_question(self, question: Question) -> Question:
        # Implement your AI logic here
        pass
    
    async def generate_overall_explanation(self, solved_questions: List[Question]) -> str:
        # Implement explanation generation
        pass
```

### 2. Register Provider

```python
from services.ai_providers.provider_factory import AIProviderFactory
from services.ai_providers.my_provider import MyCustomProvider

# Register the new provider
AIProviderFactory.register_provider("mycustom", MyCustomProvider)

# Use it
provider = AIProviderFactory.get_provider("mycustom")
```

## 🐛 Troubleshooting

### Common Issues

#### 1. "Provider not available"
- Check if API key is set correctly
- Verify API key is valid and has quota
- Check network connectivity

#### 2. "JSON parsing error" (Gemini)
- Gemini sometimes returns responses with markdown formatting
- The provider automatically handles this, but complex responses might need manual parsing

#### 3. "Rate limit exceeded"
- Add retry logic with exponential backoff
- Switch to a provider with higher limits
- Implement request queuing

### Debug Mode

Set `DEBUG=True` in your environment to see detailed provider information:

```bash
export DEBUG=True
```

This will show:
- Which provider was selected
- API call details
- Error messages
- Fallback behavior

## 📊 Performance Comparison

| Provider | Speed | Accuracy | Cost | Rate Limits |
|----------|-------|----------|------|-------------|
| **Gemini Pro** | ⚡⚡⚡ | ⭐⭐⭐⭐ | 💰 | 60/min free |
| **GPT-4** | ⚡⚡ | ⭐⭐⭐⭐⭐ | 💰💰💰 | Tier dependent |
| **Mock** | ⚡⚡⚡⚡ | ⭐⭐ | Free | Unlimited |

## 🎯 Best Practices

### 1. Production Deployment
- Use Gemini for cost-effectiveness
- Set up proper error handling and fallbacks
- Monitor API usage and costs
- Implement rate limiting

### 2. Development
- Use mock provider for initial development
- Test with real providers before deployment
- Set up proper environment variable management

### 3. Scalability
- Consider implementing provider load balancing
- Add request queuing for high-volume scenarios
- Monitor provider performance and switch if needed

## 🚀 Getting Started Checklist

- [ ] Choose your preferred AI provider
- [ ] Get API key from provider
- [ ] Set environment variables
- [ ] Test with `python test_providers.py`
- [ ] Verify API endpoints work
- [ ] Deploy and monitor

The provider system is now ready for production use with easy switching between multiple AI providers!
