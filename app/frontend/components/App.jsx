import React, { useState } from 'react';

import Result from './Result';
import Form from './Form';

const App = () => {
  const [income, setIncome] = useState('');
  const [currency, setCurrency] = useState('NZD');
  const [result, setResult] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const onSubmit = async (e) => {
    e.preventDefault();
    setError(null);
    setResult(null);

    if (!income.trim()) {
      return setError('Please enter an income');
    }

    setLoading(true);

    try {
      const params = new URLSearchParams({ income: income.trim(), currency });
      const res = await fetch(`/api/v1/tax_calculation?${params}`, {
        headers: { 'Accept': 'application/json' }
      });
      const data = await res.json();
      if (!res.ok) {
        setError(data.error || 'Request failed');
      } else {
        setResult(data);
      }
    } catch (e2) {
      setError('Network error');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="p-6">
      <div className="max-w-xl mx-auto">
        <h1 className="text-2xl mb-4">Tax Calculation</h1>

        <Form
          income={income}
          currency={currency}
          loading={loading}
          error={error}
          setIncome={setIncome}
          setCurrency={setCurrency}
          onSubmit={onSubmit}
        />

        {result && !error && (
          <Result result={result} />
        )}
      </div>
    </div>
  );
};

export default App;
