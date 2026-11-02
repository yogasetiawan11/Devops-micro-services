
import React from 'react';
import { render, screen } from '@testing-library/react';
import App from './App';

test('renders Luxury Boutique application', () => {
  render(<App />);

  const headingElement = screen.getByText(/luxury boutique/i);

  expect(headingElement).toBeInTheDocument();
});
