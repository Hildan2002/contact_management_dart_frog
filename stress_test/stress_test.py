#!/usr/bin/env python3
"""
Stress Test untuk Contact Management API (Dart Frog)
====================================================

Script ini melakukan stress testing untuk API Contact Management yang dibangun dengan Dart Frog.
Termasuk testing untuk authentication dan operasi CRUD contacts.

Requirements:
- requests
- concurrent.futures
- statistics

Install dependencies:
pip install requests

Usage:
python stress_test.py
"""

import requests
import json
import time
import statistics
import threading
import concurrent.futures
from dataclasses import dataclass
from typing import List, Dict, Any, Optional
import random
import string


@dataclass
class TestResult:
    """Struktur data untuk menyimpan hasil test"""
    endpoint: str
    method: str
    response_time: float
    status_code: int
    success: bool
    error: Optional[str] = None


class ContactAPIStressTester:
    """Class utama untuk stress testing Contact Management API"""
    
    def __init__(self, base_url: str = "http://localhost:8080"):
        self.base_url = base_url.rstrip('/')
        self.session = requests.Session()
        self.results: List[TestResult] = []
        self.results_lock = threading.Lock()
        
    def _log_result(self, result: TestResult):
        """Thread-safe logging hasil test"""
        with self.results_lock:
            self.results.append(result)
    
    def _generate_random_string(self, length: int = 8) -> str:
        """Generate random string untuk test data"""
        return ''.join(random.choices(string.ascii_letters + string.digits, k=length))
    
    def _generate_test_user(self) -> Dict[str, str]:
        """Generate data user untuk testing"""
        username = self._generate_random_string()
        return {
            "name": f"Test User {username}",
            "email": f"test_{username}@example.com",
            "password": "TestPassword123!"
        }
    
    def _generate_test_contact(self) -> Dict[str, str]:
        """Generate data contact untuk testing"""
        first_name = self._generate_random_string(6)
        last_name = self._generate_random_string(6)
        unique_id = self._generate_random_string(4)
        return {
            "first_name": f"Contact{first_name}",
            "last_name": f"Test{last_name}",
            "email": f"contact_{unique_id}@example.com",
            "phone": f"+628{random.randint(10000000, 99999999)}"
        }
    
    def register_user(self) -> Optional[str]:
        """Register user baru dan return email jika berhasil"""
        user_data = self._generate_test_user()
        start_time = time.time()
        
        try:
            response = self.session.post(
                f"{self.base_url}/auth/register",
                json=user_data,
                headers={"Content-Type": "application/json"}
            )
            
            response_time = time.time() - start_time
            success = response.status_code == 201
            
            result = TestResult(
                endpoint="/auth/register",
                method="POST",
                response_time=response_time,
                status_code=response.status_code,
                success=success,
                error=None if success else response.text
            )
            self._log_result(result)
            
            if success:
                return user_data["email"], user_data["password"]
            return None
            
        except Exception as e:
            response_time = time.time() - start_time
            result = TestResult(
                endpoint="/auth/register",
                method="POST",
                response_time=response_time,
                status_code=0,
                success=False,
                error=str(e)
            )
            self._log_result(result)
            return None
    
    def login_user(self, email: str, password: str) -> Optional[str]:
        """Login user dan return JWT token jika berhasil"""
        login_data = {"email": email, "password": password}
        start_time = time.time()
        
        try:
            response = self.session.post(
                f"{self.base_url}/auth/login",
                json=login_data,
                headers={"Content-Type": "application/json"}
            )
            
            response_time = time.time() - start_time
            success = response.status_code == 200
            
            result = TestResult(
                endpoint="/auth/login",
                method="POST",
                response_time=response_time,
                status_code=response.status_code,
                success=success,
                error=None if success else response.text
            )
            self._log_result(result)
            
            if success:
                data = response.json()
                return data.get("data", {}).get("token")
            return None
            
        except Exception as e:
            response_time = time.time() - start_time
            result = TestResult(
                endpoint="/auth/login",
                method="POST",
                response_time=response_time,
                status_code=0,
                success=False,
                error=str(e)
            )
            self._log_result(result)
            return None
    
    def create_contact(self, token: str) -> Optional[str]:
        """Buat contact baru dan return ID jika berhasil"""
        contact_data = self._generate_test_contact()
        start_time = time.time()
        
        try:
            response = self.session.post(
                f"{self.base_url}/contacts",
                json=contact_data,
                headers={
                    "Content-Type": "application/json",
                    "Authorization": f"Bearer {token}"
                }
            )
            
            response_time = time.time() - start_time
            success = response.status_code == 201
            
            result = TestResult(
                endpoint="/contacts",
                method="POST",
                response_time=response_time,
                status_code=response.status_code,
                success=success,
                error=None if success else response.text
            )
            self._log_result(result)
            
            if success:
                data = response.json()
                return data.get("contact", {}).get("id")
            return None
            
        except Exception as e:
            response_time = time.time() - start_time
            result = TestResult(
                endpoint="/contacts",
                method="POST",
                response_time=response_time,
                status_code=0,
                success=False,
                error=str(e)
            )
            self._log_result(result)
            return None
    
    def get_contacts(self, token: str):
        """Get semua contacts"""
        start_time = time.time()
        
        try:
            response = self.session.get(
                f"{self.base_url}/contacts",
                headers={"Authorization": f"Bearer {token}"}
            )
            
            response_time = time.time() - start_time
            success = response.status_code == 200
            
            result = TestResult(
                endpoint="/contacts",
                method="GET",
                response_time=response_time,
                status_code=response.status_code,
                success=success,
                error=None if success else response.text
            )
            self._log_result(result)
            
        except Exception as e:
            response_time = time.time() - start_time
            result = TestResult(
                endpoint="/contacts",
                method="GET",
                response_time=response_time,
                status_code=0,
                success=False,
                error=str(e)
            )
            self._log_result(result)
    
    def get_contact_by_id(self, token: str, contact_id: str):
        """Get contact by ID"""
        start_time = time.time()
        
        try:
            response = self.session.get(
                f"{self.base_url}/contacts/{contact_id}",
                headers={"Authorization": f"Bearer {token}"}
            )
            
            response_time = time.time() - start_time
            success = response.status_code == 200
            
            result = TestResult(
                endpoint=f"/contacts/{contact_id}",
                method="GET",
                response_time=response_time,
                status_code=response.status_code,
                success=success,
                error=None if success else response.text
            )
            self._log_result(result)
            
        except Exception as e:
            response_time = time.time() - start_time
            result = TestResult(
                endpoint=f"/contacts/{contact_id}",
                method="GET",
                response_time=response_time,
                status_code=0,
                success=False,
                error=str(e)
            )
            self._log_result(result)
    
    def update_contact(self, token: str, contact_id: str):
        """Update contact"""
        updated_data = self._generate_test_contact()
        start_time = time.time()
        
        try:
            response = self.session.put(
                f"{self.base_url}/contacts/{contact_id}",
                json=updated_data,
                headers={
                    "Content-Type": "application/json",
                    "Authorization": f"Bearer {token}"
                }
            )
            
            response_time = time.time() - start_time
            success = response.status_code == 200
            
            result = TestResult(
                endpoint=f"/contacts/{contact_id}",
                method="PUT",
                response_time=response_time,
                status_code=response.status_code,
                success=success,
                error=None if success else response.text
            )
            self._log_result(result)
            
        except Exception as e:
            response_time = time.time() - start_time
            result = TestResult(
                endpoint=f"/contacts/{contact_id}",
                method="PUT",
                response_time=response_time,
                status_code=0,
                success=False,
                error=str(e)
            )
            self._log_result(result)
    
    def delete_contact(self, token: str, contact_id: str):
        """Delete contact"""
        start_time = time.time()
        
        try:
            response = self.session.delete(
                f"{self.base_url}/contacts/{contact_id}",
                headers={"Authorization": f"Bearer {token}"}
            )
            
            response_time = time.time() - start_time
            success = response.status_code == 200
            
            result = TestResult(
                endpoint=f"/contacts/{contact_id}",
                method="DELETE",
                response_time=response_time,
                status_code=response.status_code,
                success=success,
                error=None if success else response.text
            )
            self._log_result(result)
            
        except Exception as e:
            response_time = time.time() - start_time
            result = TestResult(
                endpoint=f"/contacts/{contact_id}",
                method="DELETE",
                response_time=response_time,
                status_code=0,
                success=False,
                error=str(e)
            )
            self._log_result(result)
    
    def run_user_flow(self):
        """Menjalankan full user flow: register -> login -> CRUD contacts"""
        # Register user
        credentials = self.register_user()
        if not credentials:
            return
        
        email, password = credentials
        
        # Login
        token = self.login_user(email, password)
        if not token:
            return
        
        # Create beberapa contacts
        contact_ids = []
        for _ in range(random.randint(2, 5)):
            contact_id = self.create_contact(token)
            if contact_id:
                contact_ids.append(contact_id)
        
        # Get all contacts
        self.get_contacts(token)
        
        # Random operations pada contacts yang sudah dibuat
        for contact_id in contact_ids:
            operations = [
                lambda: self.get_contact_by_id(token, contact_id),
                lambda: self.update_contact(token, contact_id),
            ]
            
            # Pilih random operation
            operation = random.choice(operations)
            operation()
        
        # Delete beberapa contacts
        contacts_to_delete = random.sample(contact_ids, min(len(contact_ids), 2))
        for contact_id in contacts_to_delete:
            self.delete_contact(token, contact_id)
    
    def run_concurrent_test(self, num_users: int = 10, num_threads: int = 5):
        """Menjalankan concurrent stress test"""
        print(f"Memulai stress test dengan {num_users} users dan {num_threads} threads")
        print(f"Target API: {self.base_url}")
        print("-" * 60)
        
        start_time = time.time()
        
        with concurrent.futures.ThreadPoolExecutor(max_workers=num_threads) as executor:
            # Submit semua user flows
            futures = [executor.submit(self.run_user_flow) for _ in range(num_users)]
            
            # Wait untuk semua complete
            concurrent.futures.wait(futures)
        
        total_time = time.time() - start_time
        
        print(f"\nTest selesai dalam {total_time:.2f} detik")
        self.generate_report()
    
    def generate_report(self):
        """Generate laporan hasil stress test"""
        if not self.results:
            print("Tidak ada hasil test untuk dilaporkan")
            return
        
        print("\n" + "="*60)
        print("LAPORAN STRESS TEST")
        print("="*60)
        
        # Group results by endpoint
        endpoint_stats = {}
        total_requests = len(self.results)
        successful_requests = sum(1 for r in self.results if r.success)
        failed_requests = total_requests - successful_requests
        
        for result in self.results:
            key = f"{result.method} {result.endpoint}"
            if key not in endpoint_stats:
                endpoint_stats[key] = {
                    'response_times': [],
                    'success_count': 0,
                    'total_count': 0,
                    'status_codes': {}
                }
            
            endpoint_stats[key]['response_times'].append(result.response_time)
            endpoint_stats[key]['total_count'] += 1
            if result.success:
                endpoint_stats[key]['success_count'] += 1
            
            status_code = result.status_code
            if status_code not in endpoint_stats[key]['status_codes']:
                endpoint_stats[key]['status_codes'][status_code] = 0
            endpoint_stats[key]['status_codes'][status_code] += 1
        
        # Overall statistics
        print(f"\nSTATISTIK KESELURUHAN:")
        print(f"   Total Requests: {total_requests}")
        print(f"   Successful: {successful_requests} ({successful_requests/total_requests*100:.1f}%)")
        print(f"   Failed: {failed_requests} ({failed_requests/total_requests*100:.1f}%)")
        
        if self.results:
            all_response_times = [r.response_time for r in self.results if r.success]
            if all_response_times:
                print(f"   Avg Response Time: {statistics.mean(all_response_times):.3f}s")
                print(f"   Min Response Time: {min(all_response_times):.3f}s")
                print(f"   Max Response Time: {max(all_response_times):.3f}s")
                print(f"   Median Response Time: {statistics.median(all_response_times):.3f}s")
        
        # Per-endpoint statistics
        print(f"\nSTATISTIK PER ENDPOINT:")
        print("-" * 80)
        print(f"{'Endpoint':<30} {'Success Rate':<12} {'Avg Time':<10} {'Min':<8} {'Max':<8}")
        print("-" * 80)
        
        for endpoint, stats in sorted(endpoint_stats.items()):
            success_rate = stats['success_count'] / stats['total_count'] * 100
            response_times = [rt for rt in stats['response_times']]
            
            if response_times:
                avg_time = statistics.mean(response_times)
                min_time = min(response_times)
                max_time = max(response_times)
            else:
                avg_time = min_time = max_time = 0
            
            print(f"{endpoint:<30} {success_rate:>8.1f}%    {avg_time:>7.3f}s {min_time:>7.3f}s {max_time:>7.3f}s")
        
        # Status code distribution
        print(f"\nDISTRIBUSI STATUS CODE:")
        all_status_codes = {}
        for result in self.results:
            status_code = result.status_code
            if status_code not in all_status_codes:
                all_status_codes[status_code] = 0
            all_status_codes[status_code] += 1
        
        for status_code, count in sorted(all_status_codes.items()):
            percentage = count / total_requests * 100
            print(f"   {status_code}: {count} ({percentage:.1f}%)")
        
        # Error summary
        errors = [r for r in self.results if not r.success and r.error]
        if errors:
            print(f"\nCONTOH ERRORS:")
            unique_errors = {}
            for error in errors:
                error_msg = error.error[:100] + "..." if len(error.error) > 100 else error.error
                if error_msg not in unique_errors:
                    unique_errors[error_msg] = 0
                unique_errors[error_msg] += 1
            
            for error_msg, count in list(unique_errors.items())[:5]:  # Show top 5 errors
                print(f"   ({count}x) {error_msg}")
        
        print("\n" + "="*60)


def main():
    """Main function untuk menjalankan stress test"""
    print("Contact Management API Stress Tester")
    print("=" * 50)
    
    # Configuration
    BASE_URL = "http://localhost:8080"
    NUM_USERS = 150  # Jumlah user yang akan disimulasikan
    NUM_THREADS = 8  # Jumlah thread concurrent
    
    # Check if server is running
    try:
        response = requests.get(f"{BASE_URL}", timeout=5)
        print(f"Server terdeteksi di {BASE_URL}")
    except requests.exceptions.RequestException:
        print(f"Server tidak dapat diakses di {BASE_URL}")
        print("   Pastikan server Dart Frog berjalan dengan:")
        print("   dart pub global run dart_frog_cli:dart_frog dev")
        return
    
    # Run stress test
    tester = ContactAPIStressTester(BASE_URL)
    tester.run_concurrent_test(num_users=NUM_USERS, num_threads=NUM_THREADS)


if __name__ == "__main__":
    main()