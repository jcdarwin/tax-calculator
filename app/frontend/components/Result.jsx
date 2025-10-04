import React from 'react';

const Result = ({ result }) => {
  const { currency, income, total_tax } = result;
  return (
    <div className="mt-6 space-y-4">
      <div className="rounded p-4 border">
        <h2 className="text-lg mb-2">Result</h2>
        <dl className="grid grid-cols-2 gap-y-2 text-sm">
          <dt>Income:</dt>
          <dd>{currency?.symbol}{income}</dd>
          <dt>Total Tax:</dt>
          <dd>{currency?.symbol}{total_tax}</dd>
        </dl>
      </div>
    </div>
  );
}

export default Result;
