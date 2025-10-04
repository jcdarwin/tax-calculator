import React from 'react';

const Form = ({ income, currency, loading, error, setIncome, setCurrency, onSubmit }) => {
  return (
    <form onSubmit={onSubmit} className="rounded p-4 space-y-4 border">
      <div>
        <label className="block text-sm mb-1">Income (e.g. 35000 or 35000.50)</label>
        <input
          type="text"
          value={income}
          onChange={(e) => setIncome(e.target.value)}
          className="w-full rounded border px-3 py-2"
          placeholder="Enter income"
          inputMode="decimal"
        />
      </div>
      <div>
        <label className="block text-sm mb-1">Currency</label>
        <select
          value={currency}
          onChange={(e) => setCurrency(e.target.value)}
          className="w-full rounded border px-3 py-2"
        >
          <option value="NZD">NZD</option>
        </select>
      </div>
      <button
        type="submit"
        disabled={loading}
        className="inline-flex items-center rounded bg-blue-600 text-white px-4 py-2 text-sm hover:bg-blue-700 disabled:opacity-50"
      >
        {loading ? 'Calculating...' : 'Calculate Tax'}
      </button>
      {error && (
        <div className="text-sm text-red-600 bg-red-50 border border-red-200 rounded p-2">
          {error}
        </div>
      )}
    </form>
);
}

export default Form;
