#!/usr/bin/env python3
"""
UV-compatible test runner for the Mathematics Homework Solver
"""

import subprocess
import sys
import os

def run_command(cmd, description):
    """Run a command and return the result"""
    print(f"\n🧪 {description}")
    print(f"Running: {' '.join(cmd)}")
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        print(f"✅ {description} completed successfully")
        if result.stdout:
            print(result.stdout)
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ {description} failed")
        if e.stdout:
            print("STDOUT:", e.stdout)
        if e.stderr:
            print("STDERR:", e.stderr)
        return False

def main():
    """Main test runner"""
    print("=== UV Test Runner for Mathematics Homework Solver ===")
    
    # Check if UV is available
    try:
        subprocess.run(["uv", "--version"], capture_output=True, check=True)
        print("✅ UV is available")
    except subprocess.CalledProcessError:
        print("❌ UV is not available. Please install UV first:")
        print("   curl -LsSf https://astral.sh/uv/install.sh | sh")
        sys.exit(1)
    
    # Run provider tests
    print("\n" + "="*60)
    success = run_command(
        ["uv", "run", "python", "test_providers.py"],
        "Testing AI Providers"
    )
    
    if not success:
        print("❌ Provider tests failed")
        sys.exit(1)
    
    # Run API tests (if server is running)
    print("\n" + "="*60)
    api_success = run_command(
        ["uv", "run", "python", "test_api.py"],
        "Testing API Endpoints"
    )
    
    if not api_success:
        print("⚠️  API tests failed (make sure server is running)")
    
    # Run linting if available
    print("\n" + "="*60)
    lint_success = run_command(
        ["uv", "run", "black", "--check", "."],
        "Code Formatting Check"
    )
    
    # Run type checking if available
    print("\n" + "="*60)
    type_success = run_command(
        ["uv", "run", "mypy", ".", "--ignore-missing-imports"],
        "Type Checking"
    )
    
    # Summary
    print("\n" + "="*60)
    print("TEST SUMMARY:")
    print(f"✅ Provider Tests: {'PASSED' if success else 'FAILED'}")
    print(f"{'✅' if api_success else '⚠️ '} API Tests: {'PASSED' if api_success else 'FAILED/SKIPPED'}")
    print(f"{'✅' if lint_success else '⚠️ '} Code Format: {'PASSED' if lint_success else 'FAILED/SKIPPED'}")
    print(f"{'✅' if type_success else '⚠️ '} Type Check: {'PASSED' if type_success else 'FAILED/SKIPPED'}")
    
    if success:
        print("\n🎉 Core tests completed successfully!")
        return 0
    else:
        print("\n❌ Some tests failed")
        return 1

if __name__ == "__main__":
    sys.exit(main())
