# -*- coding: utf-8 -*-

# This code is part of Qiskit.
#
# (C) Copyright IBM 2017.
#
# This code is licensed under the Apache License, Version 2.0. You may
# obtain a copy of this license in the LICENSE.txt file in the root directory
# of this source tree or at http://www.apache.org/licenses/LICENSE-2.0.
#
# Any modifications or derivative works of this code must retain this
# copyright notice, and modified files need to carry a notice indicating
# that they have been altered from the originals.

"""Node for an OPENQASM expression list."""

from .node import Node


class Complex(Node):
    """Node for an OPENQASM expression list.

    children are expression nodes.
    """

    def __init__(self, children):
        """Create the complex node. Children is an expression list of reals."""
        super().__init__('complex', children, None)
        self.real = children[0].real
        self.imag = children[1].imag
        self.complex = self.real + self.imag*1j

    def qasm(self, prec=15):
        """Return the corresponding OPENQASM string."""
        return "(" + self.children[0].qasm(prec) + "," + self.children[1].qasm(prec) + ")"
